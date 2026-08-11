USE [Swiggy Database];

SELECT * FROM swiggy_data

-- Data Validation & Cleaning
-- Null Check
SELECT 
	SUM(CASE WHEN State IS NUll THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN City IS NUll THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NUll THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NUll THEN 1 ELSE 0 END) AS null_restaurant,
	SUM(CASE WHEN Location IS NUll THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Category IS NUll THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN Dish_Name IS NUll THEN 1 ELSE 0 END) AS null_dish,
	SUM(CASE WHEN Price_INR IS NUll THEN 1 ELSE 0 END) AS null_price,
	SUM(CASE WHEN Rating IS NUll THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Rating_Count IS NUll THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;


-- Blank or Empty String
SELECT * FROM swiggy_data
WHERE State='' OR Restaurant_Name='' OR Location='' OR Category='' OR Dish_Name='';

-- Duplicate Detechtion
SELECT 
State,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,
Price_INR,Rating,Rating_Count, COUNT(*) as CNT
FROM swiggy_data
GROUP BY State,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,
Price_INR,Rating,Rating_Count
HAVING COUNT(*) > 1;

-- Delete Duplication
WITH CTE AS ( SELECT *, ROW_NUMBER() OVER(
PARTITION BY State,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,
Price_INR,Rating,Rating_Count ORDER BY (SELECT NULL)) AS rn
FROM swiggy_data)

DELETE FROM CTE WHERE rn>1;


-- Create Schema
-- Date Table
CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	full_date DATE,
	year INT,
	month INT,
	month_name VARCHAR(20),
	quarter INT,
	day INT,
	week INT
)


-- dim_location
CREATE TABLE dim_location(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);

-- dim_restaurant
CREATE TABLE dim_restaurant(
	Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_Name VARCHAR(200)
);

-- dim_category
CREATE TABLE dim_category(
	Category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200)
);

-- dim_dish
CREATE TABLE dim_dish(
	Dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
);

-- Fact Table
CREATE TABLE fact_swiggy_orders(
	order_id INT IDENTITY(1,1) PRIMARY KEY,

	date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL(4,2),
	Rating_Count INT,

	location_id INT,
	Restaurant_id INT,
	Category_id INT,
	Dish_id INT,

	FOREIGN KEY(date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY(location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY(Restaurant_id) REFERENCES dim_restaurant(Restaurant_id),
	FOREIGN KEY(Category_id) REFERENCES dim_category(Category_id),
	FOREIGN KEY(Dish_id) REFERENCES dim_dish(Dish_id)
);

-- INSERT data in tables
-- dim_date
INSERT INTO dim_date(full_date, year, month, month_name, quarter, day, week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH, Order_Date),
	DATEPART(QUARTER, Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

SELECT * FROM dim_date;

-- dim_location
INSERT INTO dim_location(State,City, location)
SELECT DISTINCT
	State,
	City,
	Location
FROM swiggy_data;

SELECT * FROM dim_location;

-- dim_restaurant
INSERT INTO dim_restaurant(Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
FROM swiggy_data;

SELECT * FROM dim_restaurant;

-- dim_category
INSERT INTO dim_category(Category)
SELECT DISTINCT
	Category
FROM swiggy_data;

SELECT * FROM dim_category;

-- dim_dish
INSERT INTO dim_dish(Dish_Name)
SELECT DISTINCT
	Dish_Name 
FROM swiggy_data;

SELECT * FROM dim_dish;

-- fact_table
INSERT INTO fact_swiggy_orders
( 
	date_id,
	Price_INR,
	Rating,
	Rating_Count,
	location_id,
	Restaurant_id,
	Category_id,
	Dish_id
)

SELECT 
	dd.date_id, s.Price_INR, s.Rating, s.Rating_Count,
	dl.location_id, dr.Restaurant_id, dc.Category_id, dsh.Dish_id
FROM swiggy_data s

JOIN dim_date dd
	ON dd.full_date = s.Order_Date

JOIN dim_location dl
	ON dl.State = s.State
	AND dl.City = s.City
	AND dl.Location = s.Location

JOIN dim_restaurant dr
	ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category dc
	ON dc.Category = s.Category

JOIN dim_dish dsh
	ON dsh.Dish_Name = s.Dish_Name;


SELECT * FROM fact_swiggy_orders


-- Complete Table
SELECT * FROM fact_swiggy_orders f
JOIN  dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.Restaurant_id = r.Restaurant_id
JOIN dim_category c ON f.Category_id = c.Category_id
JOIN dim_dish di ON f.Dish_id = di.Dish_id;

-- KPI DEVELOPMENT
-- Total Orders
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

-- Total Revenue (INR Million)
SELECT
FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000, 'N2') + 'INR Million' AS Total_Revenue 
FROM fact_swiggy_orders;

-- Average Dish Price
SELECT
FORMAT(AVG(CONVERT(FLOAT,Price_INR)), 'N2') + 'INR ' AS Avg_dish_price 
FROM fact_swiggy_orders;

-- Average Rating
SELECT AVG(Rating) AS Avg_rating FROM fact_swiggy_orders;





-- Deep-Dive Business Analysis
-- Monthly Order Trends
SELECT d.year,d.month, d.month_name,
COUNT(order_id) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY d.year,d.month, d.month_name
ORDER BY COUNT(order_id) DESC;





-- Monthly Revenue
SELECT d.year,d.month, d.month_name,
SUM(Price_INR) AS Total_monthly_revenue
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY d.year,d.month, d.month_name
ORDER BY SUM(Price_INR) DESC;





-- Quarterly Trend
SELECT d.year, d.quarter,
COUNT(order_id) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY d.year, d.quarter
ORDER BY COUNT(order_id) DESC;





-- Yearly Trend
SELECT d.year,
COUNT(order_id) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY COUNT(order_id) DESC;





-- Orders by Day of Week (Mon-Sun)
SELECT DATENAME(WEEKDAY, d.full_date) AS day_name,
COUNT(order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date);




-- month generates the highest revenue
SELECT d.month_name, SUM(f.Price_INR) AS revenue
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY d.month_name
ORDER BY revenue DESC;





-- month-over-month revenue growth
WITH monthly_sales AS (
    SELECT d.Year, d.month_name, SUM(f.Price_INR) AS revenue
    FROM fact_swiggy_orders f
    JOIN dim_date d
        ON f.date_id = d.date_id
    GROUP BY d.Year,d.month_name),

previous_month AS (
    SELECT *, LAG(revenue) OVER (ORDER BY Year, month_name) AS previous_revenue
    FROM monthly_sales)

SELECT Year, month_name, revenue, previous_revenue,
     CAST((revenue - previous_revenue) * 100.0 / NULLIF(previous_revenue, 0) AS DECIMAL(10,2)) AS mom_growth_percentage
FROM previous_month
ORDER BY Year, month_name;



-- Top 10 cities by order volume
SELECT TOP 10
l.city,
COUNT(order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.city
ORDER BY total_orders DESC;




-- Revenue Contribution by States
SELECT l.state,
SUM(f.Price_INR) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.state
ORDER BY total_revenue DESC;




-- cities have the highest average-rated restaurants
SELECT
    l.City,
    AVG(f.Rating) AS avg_rating,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l
    ON f.location_id = l.location_id
GROUP BY l.City
HAVING COUNT(*) >= 100
ORDER BY avg_rating DESC;





-- percentage of total revenue comes from each state
WITH state_revenue AS
(SELECT l.State, SUM(f.Price_INR) AS revenue
    FROM fact_swiggy_orders AS f
    JOIN dim_location AS l
        ON f.location_id = l.location_id
    GROUP BY l.State)

SELECT State,revenue AS state_revenue,
    CONVERT(DECIMAL(10,2), revenue * 100.0 / NULLIF(SUM(revenue) OVER (),0)) AS revenue_percentage
FROM state_revenue
ORDER BY revenue_percentage DESC;





-- restaurants should Swiggy prioritize for promotion
SELECT
    r.Restaurant_Name,
    COUNT(*) AS total_orders,
    AVG(f.Rating) AS avg_rating,
    AVG(f.Price_INR) AS avg_price,
    SUM(f.Price_INR) AS revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
GROUP BY r.Restaurant_Name
HAVING AVG(f.Rating) >= 4.0
   AND COUNT(*) >= 100
   AND AVG(f.Price_INR) BETWEEN 150 AND 400
ORDER BY revenue DESC;





-- Identify high-value restaurants
SELECT
    r.Restaurant_Name,
    COUNT(*) AS total_orders,
    SUM(f.Price_INR) AS total_revenue,
    AVG(f.Rating) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON f.Restaurant_id = r.Restaurant_id
GROUP BY r.Restaurant_Name
HAVING SUM(f.Price_INR) > 100000
   AND AVG(f.Rating) >= 4
ORDER BY total_revenue DESC;






-- Top 10 Restaurants by orders
SELECT TOP 10
r.restaurant_name,
SUM(f.price_INR) AS Total_revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY Total_revenue DESC;




-- Top Categories by Order Volume
SELECT c.category, COUNT(order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_category c
ON f.Category_id = c.Category_id
GROUP BY c.Category
ORDER BY total_orders DESC;



-- Most Ordered Dishes
SELECT d.dish_name, COUNT(order_id) AS order_count
FROM fact_swiggy_orders f
JOIN dim_dish d
ON d.Dish_id = f.Dish_id
GROUP BY d.Dish_Name
ORDER BY order_count DESC;




-- Cuisine Performance(Orders + Avg Rating)
SELECT c.category, COUNT(order_id) AS total_orders,
AVG(f.rating) AS avg_rating 
FROM fact_swiggy_orders f
JOIN dim_category c 
ON f.Category_id = c.Category_id
GROUP BY c.Category
ORDER BY total_orders DESC;




-- restaurants contribute the most revenue
SELECT
    r.Restaurant_Name,
    COUNT(*) AS total_orders,
    SUM(f.Price_INR) AS revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON f.Restaurant_id = r.Restaurant_id
GROUP BY r.Restaurant_Name
ORDER BY revenue DESC;





-- percentage of total revenue comes from each state
WITH state_revenue AS (SELECT l.State, SUM(f.Price_INR) AS revenue
    FROM fact_swiggy_orders f
    JOIN dim_location l
        ON f.location_id = l.location_id
    GROUP BY l.State
)

SELECT State,revenue, revenue * 100.0 / SUM(revenue) OVER () AS revenue_percentage
FROM state_revenue
ORDER BY revenue DESC;





-- restaurants have high ratings but low sales
SELECT
    r.Restaurant_Name,
    COUNT(*) AS total_orders,
    AVG(f.Rating) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON f.restaurant_id = r.Restaurant_id
GROUP BY r.Restaurant_Name
HAVING AVG(f.Rating) >= 4.0
   AND COUNT(*) < 100
ORDER BY avg_rating DESC;







-- Total Orders by Price Range
SELECT 
	CASE 
		WHEN price_INR < 100 THEN 'Under 100'
		WHEN price_INR BETWEEN 100 AND 199 THEN '100-199'
		WHEN price_INR BETWEEN 200 AND 299 THEN '200-299'
		WHEN price_INR BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END AS price_range,
	COUNT(order_id) AS total_orders
FROM fact_swiggy_orders
GROUP BY 
	CASE 
		WHEN price_INR < 100 THEN 'Under 100'
		WHEN price_INR BETWEEN 100 AND 199 THEN '100-199'
		WHEN price_INR BETWEEN 200 AND 299 THEN '200-299'
		WHEN price_INR BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END
ORDER BY total_orders DESC;




-- Rating Count
SELECT rating, COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY rating
ORDER BY rating_count DESC;







