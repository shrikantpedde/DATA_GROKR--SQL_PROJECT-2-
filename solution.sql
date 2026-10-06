DROP DATABASE IF EXISTS datagrokr_week5_db;
CREATE DATABASE datagrokr_week5_db;
USE datagrokr_week5_db;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    segment VARCHAR(50)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20),
    quarter INT NOT NULL
);

CREATE TABLE fact_sales (
    sales_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    date_id INT,
    quantity INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

INSERT INTO dim_customer (customer_id, customer_name, city, segment) VALUES
(1, 'Rahul Sharma', 'Bangalore', 'Corporate'),
(2, 'Ananya Rao', 'Chennai', 'Consumer'),
(3, 'Priya Nair', 'Bangalore', 'Consumer'),
(4, 'Arun Kumar', 'Hyderabad', 'Home Office');

INSERT INTO dim_product (product_id, product_name, category, unit_price) VALUES
(101, 'Laptop', 'Electronics', 60000.00),
(102, 'Monitor', 'Electronics', 15000.00),
(103, 'Desk Chair', 'Furniture', 8000.00),
(104, 'Mechanical Keyboard', 'Electronics', 4500.00);

INSERT INTO dim_date (date_id, full_date, year, month, month_name, quarter) VALUES
(20260101, '2026-01-01', 2026, 1, 'January', 1),
(20260115, '2026-01-15', 2026, 1, 'January', 1),
(20260201, '2026-02-01', 2026, 2, 'February', 1),
(20260215, '2026-02-15', 2026, 2, 'February', 1),
(20260301, '2026-03-01', 2026, 3, 'March', 1);

INSERT INTO fact_sales (sales_id, customer_id, product_id, date_id, quantity, total_amount) VALUES
(1, 1, 101, 20260101, 1, 60000.00),
(2, 2, 102, 20260115, 2, 30000.00),
(3, 3, 103, 20260115, 1, 8000.00),
(4, 1, 104, 20260201, 2, 9000.00),
(5, 4, 101, 20260215, 1, 60000.00),
(6, 2, 103, 20260215, 3, 24000.00),
(7, 3, 101, 20260301, 1, 60000.00),
(8, 1, 102, 20260301, 1, 15000.00);

SELECT 
    c.customer_name,
    p.product_name,
    p.category,
    f.total_amount,
    DENSE_RANK() OVER (PARTITION BY p.category ORDER BY f.total_amount DESC) AS rank_in_category,
    ROW_NUMBER() OVER (ORDER BY f.total_amount DESC) AS global_sales_row
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_id = p.product_id;

WITH MonthlySales AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        SUM(f.total_amount) AS current_month_sales
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month, d.month_name
),
MoMAnalysis AS (
    SELECT 
        year,
        month,
        month_name,
        current_month_sales,
        LAG(current_month_sales, 1, 0.00) OVER (ORDER BY year, month) AS previous_month_sales
    FROM MonthlySales
)
SELECT 
    year,
    month_name,
    current_month_sales,
    previous_month_sales,
    (current_month_sales - previous_month_sales) AS mom_growth_amount,
    ROUND(
        CASE 
            WHEN previous_month_sales = 0 THEN 0
            ELSE ((current_month_sales - previous_month_sales) / previous_month_sales) * 100
        END, 2
    ) AS mom_growth_percentage
FROM MoMAnalysis;

SELECT 
    COALESCE(p.category, 'All Categories') AS category,
    COALESCE(c.city, 'All Cities') AS city,
    SUM(f.total_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY p.category, c.city WITH ROLLUP;

CREATE OR REPLACE VIEW v_customer_performance AS
WITH CustomerStats AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(f.sales_id) AS total_orders,
        SUM(f.total_amount) AS total_spent
    FROM dim_customer c
    LEFT JOIN fact_sales f ON c.customer_id = f.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    total_orders,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS customer_quartile
FROM CustomerStats;

SELECT * FROM v_customer_performance;