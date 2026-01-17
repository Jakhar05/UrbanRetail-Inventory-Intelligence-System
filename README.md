# 📦 Solving Inventory Inefficiencies Using SQL & Power BI

## 📝 Overview
Urban Retail Co. is a fast-growing mid-sized retail chain operating across multiple regions with a diverse product portfolio. Despite strong sales, the company faced persistent inventory inefficiencies that impacted profitability and operational decision-making. 

Key challenges included:

- Frequent **stockouts at store level** despite healthy regional inventory
- **Overstocking of slow-moving and obsolete SKUs**, increasing holding costs
- **Forecast inaccuracies** leading to excess safety stock
- Limited visibility into **store-wise inventory risk**
- Reactive decision-making due to lack of actionable insights

👉 **Goal:** Design and implement an end-to-end, SQL-driven inventory intelligence system that transforms raw transactional data into **clear operational insights and actionable recommendations**, supported by an interactive Power BI dashboard.

---

## 🎯 Objectives
- Normalize raw inventory data into a **clean relational database schema**
- Build analytical SQL queries to:
  - Monitor stock levels, surplus/deficit, and stock risks
  - Identify fast-moving vs slow-moving products
  - Calculate dynamic reorder points using sales velocity
  - Analyze inventory aging and turnover ratios
  - Measure forecast accuracy and bias
  - Recommend inter-store stock transfers
- Create a **Power BI dashboard** for business stakeholders to track KPIs and take informed actions

---

## 🛠 Tech Stack

| Tool      | Purpose |
|----------|--------|
| SQL Server / MySQL | Data modeling, cleaning, and analytics |
| Excel / CSV | Query exports and Power BI data source |
| Power BI | Interactive dashboards and business insights |

---

## 📌 Key Features

### ✅ Data Modeling
- Fully **normalized relational schema**
- Clear entity separation for products, stores, inventory, and pricing
- ERD created to represent relationships and data flow
- 
---

### ✅ Advanced SQL Analytics
- Stock surplus/deficit and coverage ratio analysis
- Store-level stock risk detection (masked by regional aggregation)
- Dynamic reorder point calculation using burn rate
- Inventory aging and obsolete stock identification
- Forecast accuracy analysis highlighting systematic over-forecasting
- Inter-store transfer recommendation logic with pricing and promotion constraints

---

### ✅ Power BI Dashboard
- Inventory health KPIs (Total Inventory, Demand, Net Stock Position)
- Seasonal demand trends and inventory velocity
- Fast-selling vs slow-moving product segmentation
- Store efficiency: Sales vs Supply
- Action-oriented **Final Action Plan** (HOLD / MONITOR / TRANSFER)
- Custom tooltip legend for intuitive decision-making

---

## 📈 Business Impact
- Identified **hidden store-level stock risks** despite regional surplus
- Highlighted **systematic over-forecasting (11–13 units on average)**
- Recommended inventory rebalancing to reduce holding costs
- Improved decision-making through **actionable, visual insights**
- Optimized working capital by reducing excess safety stock

---

## 🚀 How to Run

1️⃣ Execute `UrbanRetail_Inventory_Analysis.sql` to create schema and populate tables  
2️⃣ Run analytical SQL queries to generate insights  
3️⃣ Export query outputs as CSV files  
4️⃣ Load CSVs into Power BI using `UrbanRetail_Inventory_Dashboard.pbix`  
5️⃣ Interact with filters, tooltips, and visuals for analysis  

---

## 📦 Deliverables
- ✅ SQL scripts with business-focused logic
- ✅ Normalized database schema & ERD
- ✅ Power BI dashboard (`.pbix`)
- ✅ Executive Summary (PDF)
- ✅ Query outputs as CSV files

---

## 💡 Future Enhancements
- Real-time ETL pipelines for automated data ingestion
- Predictive demand forecasting using machine learning
- ERP integration for automated reorder and transfer execution
- Cost-based optimization models for inventory decisions

---

## 📂 Resources
- Dataset: `inventory_forecasting.csv`
- SQL Script: `UrbanRetail_Inventory_Analysis.sql`
- Dashboard: `UrbanRetail_Inventory_Dashboard.pbix`

---

## 👤 Author
**Sunny Kumar**  
Data Analytics & Business Intelligence Enthusiast  

🔗 GitHub: https://github.com/Jakhar05

