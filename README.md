# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner to Advance  
**Database**: `SQL Project`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE SQL Project;;

CREATE TABLE Retail_Sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve all columns for sales made in November 2022**:
```sql
Select * 
from Retail_Sales
where  DATEPART(MONTH,sale_date)=11 and DATEPART(YEAR,sale_date)=2022;  	
```

2. **Retrieve all transactions where the category is Clothing and the quantity sold is more than or equal to 3 in the month of Nov-2022**:
```sql
SELECT  * 
FROM Retail_Sales
WHERE  
          category='Clothing' 
          AND
          DATEPART(MONTH,sale_date)=11 and DATEPART(YEAR,sale_date)=2022  	
          AND 
          quantity >= 3
```

3. **Calculate the total sales for each product category**:
```sql
SELECT   
       ROUND (AVG(age),2) as Avg_age
FROM Retail_Sales
WHERE category = 'Beauty'
```

4. **Find the average age of customers who purchased items from the Beauty category**:
```sql
SELECT   
       ROUND (AVG(age),2) as Avg_age
FROM Retail_Sales
WHERE category = 'Beauty'
```

5. **Find the total number of transactions completed by each gender across different product categories**:
```sql
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
```

6. **Calculate the average sales per month and determine the best-selling month of each year.**:
```sql
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
```

7. **Calculate the number of orders per shift that is for Morning: Before 12:00, Afternoon: Between 12:01 and 17:00, Evening: After 17:00,**:
```sql
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
GROUP BY Shift
```

8. **Find if there is a spending difference between male and female customers in each category**:
```sql
SELECT 
    category,
    gender,
    ROUND(SUM(total_sale), 2) AS total_spending,
    ROUND(AVG(total_sale), 2) AS avg_spending_per_transaction
FROM Retail_Sales
GROUP BY category, gender
ORDER BY category, total_spending DESC
```

9. **Find the repeat customers who made at least 3 purchases**:
```sql
SELECT 
    customer_id,
    COUNT(DISTINCT transactions_id) AS purchase_count,
    SUM(total_sale) AS total_spent
FROM Retail_Sales
GROUP BY customer_id
HAVING COUNT(DISTINCT transactions_id) >= 3
ORDER BY purchase_count DESC, total_spent DESC;
```

10. **Identify peak shopping hours during the day (group sales by hour)**:
```sql
SELECT 
    DATEPART(HOUR, sale_time) AS sale_hour,
    COUNT(*) AS total_sales,
    SUM(total_sale) AS total_revenue
FROM Retail_Sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY total_sales DESC;
```

11. **Find the category with the highest revenue contribution during weekends vs weekdays**:
```sql
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
```

12. **Find the top 3 categories for each gender**:
```sql
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
```

13. **Calculate the 30-day moving average revenue**:
```sql
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
```


## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

Developed end-to-end SQL solutions including database setup, data cleaning, and exploratory analysis to extract actionable insights on sales trends, customer behavior, and product performance, supporting informed business decisions. The insights derived from this project can inform strategic business decisions by highlighting sales trends, customer behavior, and product performance.

 

## Author - Chitran Khatri

This project is part of my portfolio, showcasing the SQL skills essential for Data Analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch in me on **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/chitrankhatri/)

Thank you for your support, and I look forward to connecting with you!
