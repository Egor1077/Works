--------------------------------------------------------------------------------------------------------------------------------
-- 1. Getting a list of the most profitable products
SELECT 
    p.product_name, 
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 10;
--------------------------------------------------------------------------------------------------------------------------------
-- 2. Search for the most active clients (by number of orders)
SELECT 
    c.customer_id, 
    c.company_name, 
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name
ORDER BY order_count DESC
LIMIT 10;
--------------------------------------------------------------------------------------------------------------------------------
-- 3. The busiest employees (by number of orders processed)
SELECT 
    e.employee_id, 
    e.first_name || ' ' || e.last_name AS employee_name, 
    COUNT(o.order_id) AS processed_orders
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY processed_orders DESC;
--------------------------------------------------------------------------------------------------------------------------------
-- 4. Calculating orders by country
SELECT 
    c.country, 
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_orders DESC;
--------------------------------------------------------------------------------------------------------------------------------
-- 5. Average delivery time for orders by country
SELECT 
    c.country, 
    ROUND(AVG(o.shipped_date - o.order_date), 2) AS avg_delivery_time
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.shipped_date IS NOT NULL
GROUP BY c.country
ORDER BY avg_delivery_time;
--------------------------------------------------------------------------------------------------------------------------------
-- 6. Top 5 products by sales volume over the past year
SELECT 
    p.product_name, 
    SUM(od.quantity) AS total_sold
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_date >= (
    SELECT MAX(DATE_TRUNC('year', order_date)) - INTERVAL '1 year' 
    FROM orders
)
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;
--------------------------------------------------------------------------------------------------------------------------------
-- 7. Orders that took the longest to process
SELECT 
    order_id, 
    order_date, 
    shipped_date, 
    (shipped_date - order_date) AS processing_time
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY processing_time DESC
LIMIT 10;
--------------------------------------------------------------------------------------------------------------------------------
-- 8. Total sales of each employee
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name, 
    SUM(od.quantity * od.unit_price) AS total_sales
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY employee_name
ORDER BY total_sales DESC;
--------------------------------------------------------------------------------------------------------------------------------
-- 9. Average order amount per customer
SELECT 
    c.customer_id, 
    c.company_name, 
    ROUND(AVG(od.quantity * od.unit_price),2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY avg_order_value DESC;
--------------------------------------------------------------------------------------------------------------------------------
-- 10. Window functions: customer rating by total spending
SELECT 
    c.customer_id, 
    c.company_name, 
    SUM(od.quantity * od.unit_price) AS total_spent,
    DENSE_RANK() OVER (ORDER BY SUM(od.quantity * od.unit_price) DESC) AS rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY rank;