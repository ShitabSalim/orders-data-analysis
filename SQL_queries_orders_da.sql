select * from df_orders;











--Top 10 Highest Revenue Generating Products 
SELECT TOP 10 product_id, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY product_id
ORDER BY total_sales DESC;



--Top 5 Highest Selling Products in Each Region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT region, product_id, total_sales
FROM (
    SELECT region, product_id, total_sales,
           ROW_NUMBER() OVER(PARTITION BY region ORDER BY total_sales DESC) AS rn
    FROM cte
) AS ranked
WHERE rn <= 5;




--Month-Over-Month Growth Comparison (2022 vs 2023)
WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM monthly_sales
GROUP BY order_month
ORDER BY order_month;




--For Each Category, Which Month Had Highest Sales
WITH category_monthly_sales AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT category, order_year_month, total_sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_sales DESC) AS rn
    FROM category_monthly_sales
) AS ranked
WHERE rn = 1;




--Sub-Category with Highest Growth in Sales (2023 vs 2022)
WITH yearly_sales AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
pivoted_sales AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
    FROM yearly_sales
    GROUP BY sub_category
)
SELECT TOP 1 
    sub_category,
    sales_2022,
    sales_2023,
    (sales_2023 - sales_2022) AS sales_growth
FROM pivoted_sales
ORDER BY sales_growth DESC;

