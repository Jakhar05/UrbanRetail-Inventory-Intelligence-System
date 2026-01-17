# UrbanRetail-Inventory-Intelligence-System
📌 Project Overview

The UrbanRetail Inventory Intelligence System is an end-to-end inventory analytics project designed to improve supply chain efficiency for a multi-store retail chain.
Using SQL for data modeling and analysis and Power BI for visualization, the project identifies stock imbalances, evaluates forecast accuracy, optimizes reorder decisions, and recommends inter-store stock transfers.
The system highlights how regional-level aggregation can mask critical store-level risks and demonstrates data-driven decision-making for inventory optimization.

🎯 Business Objectives
Detect overstock and understock risks at store and product levels
Identify inventory aging and obsolete stock
Evaluate demand forecast accuracy
Recommend dynamic reorder points
Enable inter-store transfer decisions to reduce holding costs

🗂 Dataset Description
The dataset represents transactional inventory data for a multi-region retail business and includes:
Inventory levels and units sold
Demand forecasts and reorder quantities
Pricing, discounts, promotions, and competitor pricing
Weather and seasonality indicators
Source data was normalized into relational tables to maintain data integrity and scalability.

🧱 Data Model (ERD)
The project follows a normalized relational schema:

Tables
products — Product master data
stores — Store reference table
inventory — Core transactional inventory data
pricing_conditions — External factors affecting demand and pricing
Entity Relationship Diagram

🛠️ Technology Stack
SQL Server — Data modeling, transformations, and analytics
Power BI — Dashboarding and business intelligence
Excel / CSV — Intermediate analytical outputs
GitHub — Version control and project documentation

📊 Key Analyses Performed
1️⃣ Stock Visibility & Risk Detection
Region and product-level stock visibility
Identification of hidden store-level stockouts
Stock-to-demand coverage ratio alerts

2️⃣ Inventory Aging Analysis
Estimated days to inventory depletion
Classification into:
Healthy (0–3 months)
Slow-moving (3–6 months)
Obsolete (6+ months)

3️⃣ Forecast Accuracy Evaluation
Comparison of actual sales vs demand forecasts
Identification of systematic over-forecasting
Average forecast error analysis

4️⃣ Reorder Point Optimization
Burn-rate-based reorder point calculation
Lead time and safety stock considerations
Dynamic reorder recommendations

5️⃣ Inter-Store Transfer Recommendation
Detection of surplus and deficit stores
Transfer logic refined using:
Promotions
Pricing advantage
Competitor pricing
Final action classification:
TRANSFER
HOLD
MONITOR

📈 Power BI Dashboard Features
Interactive slicers for product, store, region, and promotions
Conditional formatting for stock gaps
Action-oriented indicators (Transfer / Hold / Monitor)
Custom tooltip legends for inventory interpretation

📁 Repository Structure
UrbanRetail-Inventory-Intelligence-System/
│
├── README.md
├── UrbanRetail_Inventory_Analysis.sql
├── UrbanRetail_Inventory_Dashboard.pbix
├── data/
│   ├── inventory_forecasting.csv
│   ├── forecast_accuracy_analysis.csv
│   ├── inventory_aging_analysis.csv
│   ├── reorder_point_analysis.csv
│   ├── stock_adjustment_recommendation.csv
│
├── images/
│   ├── dashboard_overview.png
│   ├── stock_adjustment_table.png
│   ├── tooltip_inventory_legend.png
│   ├── erd.png
│
└── UrbanRetail_Problem_Statement.pdf

📌 Key Insights & Findings
Regional aggregation masked store-level understock risks
Demand forecasts consistently overestimated demand by 11–13 units
Several SKUs showed high inventory aging, indicating excess holding cost
Inter-store transfers provided a cost-effective alternative to reordering

🚀 Business Impact
Reduced capital lock-in due to overstock
Improved inventory turnover
Smarter, context-aware transfer decisions
Enhanced operational visibility for decision-makers

📄 How to Use
Run UrbanRetail_Inventory_Analysis.sql in SQL Server
Load generated CSVs into Power BI
Open UrbanRetail_Inventory_Dashboard.pbix
Explore insights using slicers and tooltips
