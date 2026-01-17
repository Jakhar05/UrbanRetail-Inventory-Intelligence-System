/*******************************************************************************
PROJECT: UrbanRetail Inventory Intelligence System
OBJECTIVE: Optimize supply chain efficiency by identifying overstocking, 
           predicting reorder points, and recommending inter-store transfers.
KEY FINDINGS: 
- Identified store-level stockouts masked by regional aggregation.
- Discovered systematic over-forecasting (Average Error: -11 to -13 units).
- Recommended rebalancing stock to reduce high holding costs in "Obsolete" items.
*******************************************************************************/

CREATE DATABASE UrbanRetail_Inventory;
USE UrbanRetail_Inventory;

-- CREATE NORMALIZED SCHEMA
-- 1) Products (Unique list)
CREATE TABLE products(
product_id VARCHAR(20) PRIMARY KEY,
category VARCHAR(50)
); 
-- 2)Stores (Unique list of IDs only)
-- Note: Region was moved to transaction tables because 
-- Store_IDs in source data were mapped to multiple regions.
CREATE TABLE stores(
store_id VARCHAR(20) PRIMARY KEY
);
-- 3)Inventory (Main transaction table)
CREATE TABLE inventory(
inventory_id INT IDENTITY(1,1) PRIMARY KEY,
date DATE,
store_id VARCHAR(20),
product_id VARCHAR(20),
region VARCHAR(50), -- Region is kept here to maintain data fidelity per transaction.
inventory_level INT,
units_sold INT,
units_ordered INT,
demand_forecast FLOAT,
FOREIGN KEY (store_id) REFERENCES stores(store_id),
FOREIGN KEY(product_id) REFERENCES products(product_id)
);
-- 4)Pricing Conditions
CREATE TABLE pricing_conditions (
condition_id INT IDENTITY(1,1) PRIMARY KEY,
[date] DATE,
store_id VARCHAR(20),
product_id VARCHAR(20),
region VARCHAR(50),-- Region is kept here to maintain data fidelity per transaction.
price FLOAT,
discount INT,
weather_condition VARCHAR(50),
holiday_promotion BIT,
competitor_pricing FLOAT,
seasonality VARCHAR(20),
FOREIGN KEY (store_id) REFERENCES stores(store_id),
FOREIGN KEY(product_id) REFERENCES products(product_id)
);
-- Populate Parent Tables
INSERT INTO products (product_id, category)
SELECT DISTINCT Product_ID, Category FROM inventory_forecasting;

INSERT INTO stores (store_id)
SELECT DISTINCT Store_ID FROM inventory_forecasting;

-- Populate Child Tables (Transactional Data)
INSERT INTO inventory (
    [date], store_id, product_id, region, 
    inventory_level, units_sold, units_ordered, demand_forecast
)
SELECT 
    CAST([Date] AS DATE), 
    Store_ID, Product_ID, Region, 
    Inventory_Level, Units_Sold, Units_Ordered, Demand_Forecast
FROM inventory_forecasting;
    
INSERT INTO pricing_conditions (
    [date], store_id, product_id, region, 
    price, discount, weather_condition, holiday_promotion, competitor_pricing, seasonality
)
SELECT 
    CAST([Date] AS DATE),
    Store_ID, Product_ID, Region, 
    Price, Discount, Weather_Condition, Holiday_Promotion, Competitor_Pricing, Seasonality
FROM inventory_forecasting;

-- STOCK VISIBILITY & OPERATIONAL CONTROL
-- Stock Level by Region & Product
SELECT 
    region,
    product_id,
    SUM(inventory_level) AS total_stock_on_hand, 
    SUM(demand_forecast) AS projected_demand,
    SUM(inventory_level) - SUM(demand_forecast) AS stock_surplus_deficit -- Calculate safety stock buffer
FROM inventory
GROUP BY region,product_id
ORDER BY region,stock_surplus_deficit;
-- OPERATIONAL VIEWS (For Business Intelligence)
GO -- Use GO to start a new batch
CREATE VIEW vw_Regional_Stock_Visibility AS
SELECT 
    region,
    product_id,
    SUM(inventory_level) AS total_stock_on_hand,      -- Added "AS total_stock"
    SUM(units_ordered) AS incoming_stock,      -- Added "AS incoming_stock"
    SUM(demand_forecast) AS projected_demand    -- Added "AS forecasted_need"
FROM inventory
GROUP BY region, product_id;
GO
-- Stock Alert System
SELECT 
    region,
    product_id,
    total_stock_on_hand,
    projected_demand,
    -- Calculate the ratio (Stock divided by Demand)
    ROUND(total_stock_on_hand / NULLIF(projected_demand, 0), 2) AS stock_coverage_ratio,
    -- Create the Alert Logic
    CASE 
        WHEN (total_stock_on_hand / NULLIF(projected_demand, 0)) < 1.10 THEN 'CRITICAL: REORDER NOW'
        WHEN (total_stock_on_hand / NULLIF(projected_demand, 0)) BETWEEN 1.10 AND 1.25 THEN 'WARNING: LOW STOCK'
        ELSE 'HEALTHY'
    END AS operational_status
FROM vw_Regional_Stock_Visibility
ORDER BY stock_coverage_ratio ASC;
-- "All 30 products across all 4 regions maintained a Healthy status,
--  with a minimum stock-to-demand ratio of 1.29 (South, P0046)."

-- DETAILED STORE-LEVEL RISK ANALYSIS
SELECT 
    store_id,
    product_id,
    region,
    inventory_level,
    demand_forecast,
    (inventory_level - demand_forecast) AS units_above_demand
FROM inventory
WHERE inventory_level < (demand_forecast * 1.1) 
ORDER BY (inventory_level - demand_forecast) ASC;

-- This query calculates the Burn Rate and suggests a dynamic Reorder Point
SELECT 
    i.product_id,
    p.category,
    i.region,
    SUM(i.units_sold) / 30.0 AS avg_daily_sales, -- Assuming 30-day window
    i.inventory_level AS current_stock,
    -- Estimating ROP: (Daily Sales * 7 day lead time) + 20% Safety Buffer
    ROUND((SUM(i.units_sold) / 30.0 * 7) * 1.20, 0) AS calculated_reorder_point,
    CASE 
        WHEN i.inventory_level <= ROUND((SUM(i.units_sold) / 30.0 * 7) * 1.20, 0) THEN 'TRIGGER REORDER'
        ELSE 'SUFFICIENT'
    END AS reorder_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id
GROUP BY i.product_id, p.category, i.region, i.inventory_level;

-- Inventory Aging
SELECT 
    store_id, 
    product_id,
    inventory_level,
    units_sold,
    -- Cap the days at 365 so the charts don't look distorted
    CASE 
        WHEN units_sold = 0 THEN 365 
        WHEN (inventory_level / (NULLIF(units_sold, 0) / 30.0)) > 365 THEN 365
        ELSE ROUND(inventory_level / (NULLIF(units_sold, 0) / 30.0), 0) 
    END AS days_to_deplete,
    -- Clean Category Logic
    CASE 
        WHEN units_sold = 0 OR (inventory_level / (NULLIF(units_sold, 0) / 30.0)) > 180 THEN 'Over 6 Months (Obsolete)'
        WHEN (inventory_level / (NULLIF(units_sold, 0) / 30.0)) > 90 THEN '3-6 Months (Slow)'
        ELSE '0-3 Months (Healthy)'
    END AS inventory_age_status
FROM inventory;

-- INVENTORY TURNOVER ANALYSIS
-- High ratio = Efficiency; Low ratio = Capital tied up in dust.
SELECT 
    p.category,
    i.product_id,
    AVG(i.units_sold) AS total_units_sold,
    AVG(i.inventory_level) AS avg_stock_level,
    ROUND(AVG(CAST(i.units_sold AS FLOAT)) / NULLIF(AVG(i.inventory_level), 0), 2) AS turnover_ratio
FROM inventory i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.category, i.product_id
ORDER BY turnover_ratio DESC;

-- SUMMARY KPI: STOCKOUT RATE BY REGION
-- Measures the percentage of instances where inventory was 0
SELECT 
    region,
    COUNT(*) AS total_records,
    SUM(CASE WHEN inventory_level = 0 THEN 1 ELSE 0 END) AS stockout_instances,
    ROUND(CAST(SUM(CASE WHEN inventory_level = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 2) AS stockout_rate_pct
FROM inventory
GROUP BY region;
/* "The 0% stockout rate across all regions, combined with high inventory aging in certain SKUs,
    suggests significant over-stocking.
    I recommend reducing the safety stock buffer by 10-15% to free up capital without risking service levels." */
    
-- FORECAST ACCURACY ANALYSIS
-- Tells us if we are over-forecasting (wasting money) or under-forecasting (stockouts)
SELECT 
    product_id,
    AVG(demand_forecast) AS avg_forecast,
    AVG(units_sold) AS avg_actual_sales,
    ROUND(AVG(units_sold) - AVG(demand_forecast), 2) AS forecast_error_units
FROM inventory
GROUP BY product_id;

-- Seasonal Demand Analysis
SELECT 
    p.category,
    pc.seasonality,
    pc.weather_condition,
    SUM(i.units_sold) AS total_units_sold,
    AVG(i.inventory_level) AS avg_stock_during_period,
    -- Calculation to see if sales spike in specific weather
    ROUND(AVG(CAST(i.units_sold AS FLOAT)), 2) AS avg_daily_sales
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN pricing_conditions pc 
    ON i.product_id = pc.product_id 
    AND i.store_id = pc.store_id 
    AND i.date = pc.date
GROUP BY p.category, pc.seasonality, pc.weather_condition
ORDER BY p.category, total_units_sold DESC;

--  INTER-STORE TRANSFER RECOMMENDATION
-- Comparing Net Buffer (Inventory - Demand) to find rebalancing opportunities
SELECT 
    p.category,
    i1.product_id,
    i1.region,
    i1.store_id AS Source_Store,
    (i1.inventory_level - i1.demand_forecast) AS Surplus_Available,
    i2.store_id AS Target_Store,
    (i2.demand_forecast - i2.inventory_level) AS Deficit_Needed
FROM inventory i1
JOIN inventory i2 ON i1.product_id = i2.product_id AND i1.region = i2.region
JOIN products p ON i1.product_id = p.product_id
WHERE i1.inventory_level > i1.demand_forecast  -- Store A has extra
  AND i2.inventory_level < i2.demand_forecast  -- Store B is short
  AND i1.store_id <> i2.store_id
ORDER BY Surplus_Available DESC;


-- REFINED TRANSFER LOGIC WITH EXTERNAL FACTORS
SELECT 
    i.product_id,
    i.store_id AS Source_Store,
    i.inventory_level - i.demand_forecast AS Surplus,
    pc.holiday_promotion,
    pc.discount,
    pc.competitor_pricing,
    -- Recommendation Logic: Only move if we aren't about to have a sale
    CASE 
        WHEN pc.holiday_promotion = 1 THEN 'HOLD: Promotion Pending'
        WHEN pc.price < pc.competitor_pricing THEN 'HOLD: Price Advantage'
        WHEN i.inventory_level - i.demand_forecast > 50 THEN 'TRANSFER: Excessive Surplus'
        ELSE 'MONITOR'
    END AS final_action_plan
FROM inventory i
JOIN pricing_conditions pc 
    ON i.product_id = pc.product_id 
    AND i.store_id = pc.store_id 
    AND i.date = pc.date;


