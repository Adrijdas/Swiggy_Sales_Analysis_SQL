# 🍔 Swiggy Sales Analysis — SQL Analytics Project

An end-to-end **SQL Data Analytics project** focused on analyzing Swiggy food-delivery order data to derive actionable business insights. The project covers **data quality validation, data cleaning, dimensional modelling using a Star Schema, ETL, KPI development, and advanced SQL-based business analysis**.

---

## 📌 Project Overview

This project analyzes **1,97,401 Swiggy order records** containing information about states, cities, locations, restaurants, food categories, dishes, prices, customer ratings, and rating counts.

The objective is to transform raw food-delivery data into a structured analytical model and use SQL to answer important business questions around:

* Sales and revenue performance
* Order trends
* Geographic performance
* Restaurant performance
* Food-category and dish performance
* Customer spending behavior
* Customer ratings
* Revenue contribution
* Business growth opportunities

The project follows an end-to-end analytics workflow:

**Raw Data → Data Validation → Data Cleaning → Dimensional Modelling → ETL → KPI Development → Business Analysis**

---

## 🎯 Business Objectives

The key objectives of this project are to:

1. Validate the quality and consistency of raw Swiggy order data.
2. Identify and remove duplicate records.
3. Build a scalable **Star Schema** for analytics.
4. Create dimension and fact tables from the cleaned dataset.
5. Develop important business KPIs.
6. Analyze order and revenue trends over time.
7. Identify high-performing cities, states, restaurants, categories, and dishes.
8. Analyze customer spending patterns.
9. Analyze rating distributions and customer satisfaction.
10. Identify potential business opportunities such as highly rated restaurants with low order volume.

---

## 📊 Dataset

The raw dataset contains approximately:

**197,401 order records**

Key attributes include:

| Column            | Description                          |
| ----------------- | ------------------------------------ |
| `State`           | Geographic state of the order        |
| `City`            | City where the order was placed      |
| `Order_Date`      | Date of the order                    |
| `Restaurant_Name` | Restaurant associated with the order |
| `Location`        | Specific location or area            |
| `Category`        | Food/cuisine category                |
| `Dish_Name`       | Ordered dish                         |
| `Price_INR`       | Dish price in Indian Rupees          |
| `Rating`          | Customer rating                      |
| `Rating_Count`    | Number of ratings received           |

---

# 🧹 1. Data Cleaning & Validation

Before performing analysis, the raw dataset was systematically checked for data-quality issues.

### Null Value Analysis

Checked critical business columns for missing values, including:

* State
* City
* Order Date
* Restaurant Name
* Location
* Category
* Dish Name
* Price
* Rating
* Rating Count

### Empty String Validation

Identified blank or empty-string values that could affect downstream analysis.

### Duplicate Detection

Duplicate records were identified by grouping across business-critical columns.

### Duplicate Removal

Used the SQL `ROW_NUMBER()` window function to identify duplicate records and retain a single clean record.

Example approach:

```sql
ROW_NUMBER() OVER (
    PARTITION BY business_columns
    ORDER BY ...
)
```

This ensures that duplicate records do not distort order counts, revenue calculations, or other KPIs.

---

# 🏗️ 2. Dimensional Modelling

The cleaned dataset was transformed into a **Star Schema** to create a structured analytical data model.

Instead of keeping all attributes in one large table, descriptive information was separated into dimension tables while measurable business data was maintained in a central fact table.

### Dimension Tables

The project includes the following dimension tables:

```text
dim_date
dim_location
dim_restaurant
dim_category
dim_dish
```

### Fact Table

The central fact table is:

```text
fact_swiggy_orders
```

The fact table contains measures such as:

* `Price_INR`
* `Rating`
* `Rating_Count`

and foreign-key relationships to the relevant dimension tables.

### Star Schema

```text
                    dim_date
                       |
                       |
dim_location ---- fact_swiggy_orders ---- dim_restaurant
                       |
                       |
                 dim_category
                       |
                       |
                    dim_dish
```

This structure provides a cleaner and more scalable foundation for analytical queries and reporting.

---

# 🔄 3. ETL Process

The project follows an SQL-based ETL workflow:

### Step 1 — Load Raw Data

The raw Swiggy dataset is loaded into the source table:

```text
swiggy_data
```

### Step 2 — Profile the Data

Performed:

* Null checks
* Empty-string checks
* Duplicate detection
* Data-quality validation

### Step 3 — Clean the Data

Duplicate records were identified and removed.

### Step 4 — Create Dimension Tables

Distinct values were extracted from the cleaned source dataset and inserted into the dimension tables.

### Step 5 — Create Fact Table

The cleaned source data was joined with the dimension tables to resolve the required foreign keys.

### Step 6 — Load Analytical Model

The final Star Schema was populated and prepared for business analysis.

---

# 📈 4. Key Performance Indicators

The project calculates several core business KPIs.

### Total Orders

Measures the total number of unique orders.

### Total Revenue

Calculates total revenue generated from dish prices and presents the result in INR millions.

### Average Dish Price

Measures the average price of dishes across orders.

### Average Rating

Measures the average customer rating across dishes.

---

# 📅 5. Date-Based Analysis

SQL queries were developed to analyze business performance over time.

The analysis includes:

* Monthly order trends
* Monthly revenue
* Quarterly order trends
* Yearly order volume
* Day-of-week order patterns
* Highest-revenue month
* Month-over-month revenue growth

The project uses SQL techniques such as:

* `GROUP BY`
* Date functions
* `CTE`
* `LAG()`
* Aggregation
* Ranking

---

# 📍 6. Location-Based Analysis

Geographic performance was analyzed at both city and state levels.

Business questions include:

* What are the top 10 cities by order volume?
* Which states contribute the most revenue?
* Which cities have the highest average restaurant ratings?
* What percentage of total revenue comes from each state?
* Which restaurants should be prioritized for promotion?
* Which restaurants generate the highest business value?

---

# 🍽️ 7. Restaurant & Food Performance

Restaurant and food-level analysis was performed to understand product and merchant performance.

The analysis includes:

* Top restaurants by order volume
* Top restaurants by revenue
* High-value restaurants
* Restaurant ranking based on multiple business metrics
* Top food categories
* Most ordered dishes
* Cuisine performance
* Average rating by cuisine
* Restaurants with high ratings but low sales

The final analysis helps identify both **high-performing restaurants** and potential **growth opportunities**.

---

# 💰 8. Customer Spending Analysis

Orders were grouped into different price ranges to understand customer spending behavior.

| Spend Bucket | Description               |
| ------------ | ------------------------- |
| Under ₹100   | Low-value orders          |
| ₹100–₹199    | Budget-conscious orders   |
| ₹200–₹299    | Mid-range orders          |
| ₹300–₹499    | Premium orders            |
| ₹500+        | High-value / large orders |

This analysis helps understand how order volume is distributed across different spending levels.

---

# ⭐ 9. Rating Analysis

Customer ratings were analyzed to understand satisfaction patterns.

The project examines:

* Rating distribution from 1 to 5
* Number of orders by rating
* Relationship between ratings and order volume
* High-rated restaurants with low order volume

This analysis can help identify restaurants that have strong customer satisfaction but may require additional visibility or promotional support.

---

# 🧠 10. SQL Concepts Demonstrated

This project demonstrates practical SQL skills relevant to Data Analyst roles, including:

* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* Aggregate Functions
* `COUNT()`
* `SUM()`
* `AVG()`
* `CASE`
* `JOIN`
* Common Table Expressions (`CTE`)
* Window Functions
* `ROW_NUMBER()`
* `LAG()`
* Date-based analysis
* Ranking
* Percentage calculations
* Data-quality validation
* Duplicate detection
* Dimensional modelling
* Fact and dimension tables
* ETL using SQL

---

# 💼 Business Insights

The analysis is designed to answer practical business questions such as:

* Which cities generate the highest order volumes?
* Which states contribute the largest share of revenue?
* Which months generate the highest revenue?
* How does revenue change month over month?
* Which restaurants are the strongest revenue contributors?
* Which food categories are most popular?
* Which dishes receive the highest order volume?
* Which restaurants have high ratings but low sales?
* How are customer orders distributed across spending ranges?
* What does the rating distribution indicate about customer satisfaction?

These insights can support decisions related to **restaurant promotion, geographic expansion, menu strategy, customer engagement, and revenue growth**.

---

# 🛠️ Tools & Technologies

| Tool / Technology        | Purpose                                        |
| ------------------------ | ---------------------------------------------- |
| **SQL**                  | Data cleaning, transformation and analysis     |
| **SQL Window Functions** | Ranking, duplicate handling and trend analysis |
| **CTEs**                 | Building modular analytical queries            |
| **Star Schema**          | Dimensional data modelling                     |
| **ETL**                  | Loading cleaned data into analytical tables    |
| **GitHub**               | Project documentation and version control      |

---

# 🚀 Project Workflow

```text
             RAW SWIGGY DATA
                    │
                    ▼
          DATA QUALITY CHECKS
          ┌─────────┼─────────┐
          ▼         ▼         ▼
        NULLS     BLANKS   DUPLICATES
          │         │         │
          └─────────┼─────────┘
                    ▼
             DATA CLEANING
                    │
                    ▼
          DIMENSIONAL MODEL
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
     DIMENSIONS            FACT TABLE
          │                   │
          └─────────┬─────────┘
                    ▼
              SQL ANALYSIS
                    │
                    ▼
             BUSINESS KPIs
                    │
                    ▼
           BUSINESS INSIGHTS
```

---

# 📌 Project Outcome

By completing this project, raw Swiggy order data was transformed into a structured analytical model capable of supporting business reporting and deeper analysis.

The project successfully covers:

* **197,401 raw order records**
* Data-quality validation
* Duplicate identification and removal
* Star Schema design
* Dimension and fact table creation
* SQL-based ETL
* KPI development
* Time-series analysis
* Geographic analysis
* Restaurant analysis
* Food and cuisine analysis
* Customer spending analysis
* Rating analysis
* Business opportunity identification

---

# 👨‍💻 Author

**Adrij Das**

Data Analyst | SQL | Python | Excel | Power BI

This project was developed as part of my Data Analytics portfolio to demonstrate practical SQL, data modelling, data cleaning, ETL, and business-analysis capabilities.

---

## ⭐ If you find this project useful

Feel free to explore the SQL queries, analytical workflow, and data model. Feedback and suggestions are welcome.
