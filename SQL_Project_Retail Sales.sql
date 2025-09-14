--Retail Sales Analysis SQL Project

CREATE DATABASE SQL Project;

DROP TABLE IF EXISTS Retail_Sales;
CREATE TABLE Retail_Sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM Retail_Sales

--Data Cleaning & Preparation

--Total number of records in the dataset. 

SELECT COUNT(*) FROM Retail_Sales;

--Total number of unique customers present in the dataset.

SELECT COUNT(DISTINCT customer_id) FROM Retail_Sales;

--Extract all distinct product categories and count how many unique categories exist.

SELECT DISTINCT category FROM Retail_Sales;

--Check for NULL or missing values across key columns in the dataset, Remove if found any.

SELECT * FROM Retail_Sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;


DELETE FROM Retail_Sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

--Data Analysis and Business Key Problems & Solutions

Q.1 --Retrieve all columns for sales made in November 2022

Select * 
from Retail_Sales
where  DATEPART(MONTH,sale_date)=11 and DATEPART(YEAR,sale_date)=2022  	


Q.2--Retrieve all transactions where the category is Clothing and the quantity sold is more than or equal to 3 in the month of Nov-2022

SELECT  * 
FROM Retail_Sales
WHERE  
          category='Clothing' 
          AND
          DATEPART(MONTH,sale_date)=11 and DATEPART(YEAR,sale_date)=2022  	
          AND 
          quantity >= 3


Q.3--Calculate the total sales for each product category.

SELECT 
    category,
    SUM(total_sale) as Net_sales
FROM retail_sales
GROUP BY category

Q.4--Find the average age of customers who purchased items from the Beauty category.

SELECT   
       ROUND (AVG(age),2) as Avg_age
FROM Retail_Sales
WHERE category = 'Beauty'


Q.5--Find the total number of transactions completed by each gender across different product categories.

SELECT 
    category,
    gender,
    COUNT(*) as Total_Transaction
FROM Retail_Sales
GROUP 
    BY 
    category,
    gender
ORDER BY category


Q.6--Calculate the average sales per month and determine the best-selling month of each year.

SELECT 
    year,
    month,
    avg_sale
FROM 
(
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY YEAR(sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS Rank
    FROM Retail_Sales
    GROUP BY YEAR(sale_date), MONTH(sale_date) AS t1
WHERE Rank = 1
ORDER BY year, avg_sale DESC;

Q.7 --Calculate the number of orders per shift that is for Morning: Before 12:00, Afternoon: Between 12:01 and 17:00, Evening: After 17:00, 

 WITH Hourly_sale AS
(
    SELECT *,
        CASE
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS Shift
    FROM Retail_Sales
)
SELECT 
    Shift,
    COUNT(*) AS Total_orders
FROM Hourly_sale
GROUP BY Shift;


Q.8 --Find if there is a spending difference between male and female customers in each category.

SELECT 
    category,
    gender,
    ROUND(SUM(total_sale), 2) AS total_spending,
    ROUND(AVG(total_sale), 2) AS avg_spending_per_transaction
FROM Retail_Sales
GROUP BY category, gender
ORDER BY category, total_spending DESC;


Q.9 --Find the repeat customers who made at least 3 purchases.

SELECT 
    customer_id,
    COUNT(DISTINCT transactions_id) AS purchase_count,
    SUM(total_sale) AS total_spent
FROM Retail_Sales
GROUP BY customer_id
HAVING COUNT(DISTINCT transactions_id) >= 3
ORDER BY purchase_count DESC, total_spent DESC;


Q.10 --Identify peak shopping hours during the day (group sales by hour).

SELECT 
    DATEPART(HOUR, sale_time) AS sale_hour,
    COUNT(*) AS total_sales,
    SUM(total_sale) AS total_revenue
FROM Retail_Sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY total_sales DESC;


Q.11 --Find the category with the highest revenue contribution during weekends vs weekdays.

SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, sale_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    category,
    SUM(total_sale) AS total_revenue,
    RANK() OVER (PARTITION BY 
        CASE 
            WHEN DATENAME(WEEKDAY, sale_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
        END
        ORDER BY SUM(total_sale) DESC
    ) AS revenue_rank
FROM Retail_Sales
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, sale_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END,
    category
HAVING SUM(total_sale) IS NOT NULL;

Q.12--Find the top 3 categories for each gender

SELECT * FROM 
(SELECT 
    gender,
    category,
    SUM(total_sale) AS total_revenue,
    RANK() OVER (
        PARTITION BY gender 
        ORDER BY SUM(total_sale) DESC
    ) AS category_rank
FROM Retail_Sales
GROUP BY gender, category
HAVING SUM(total_sale) IS NOT NULL) as t
where category_rank <= 3;   

Q.13 --Calculate the 30-day moving average revenue


WITH daily_revenue AS (
    SELECT 
        CAST(sale_date AS DATE) AS sale_day,
        SUM(total_sale) AS daily_revenue
    FROM Retail_Sales
    GROUP BY CAST(sale_date AS DATE)
)
SELECT 
    sale_day,
    daily_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY sale_day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_30day
FROM daily_revenue
ORDER BY sale_day;


--End of the Project





