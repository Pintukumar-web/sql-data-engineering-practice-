

---1).Show all customers--
SELECT * FROM customers;

---2).Show customers from Delhi---
SELECT *
		FROM customers
		WHERE city ='Delhi';

----3)Show products only from category Accessories---
SELECT * FROM products
	WHERE category ='Accessories';

---4).Find the most expensive product---
SELECT product_name,price
	FROM products
	order by price desc
	limit 1;

----5).Find the cheapest product----
SELECT product_name, price
	FROM products
	ORDER BY price asc
	LIMIT 1;

---6).Count total orders---

SELECT count(*) FROM orders;

----7).Count delivered orders---

SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE status = 'Delivered';

-------8).Show all orders placed in March 2025---


SELECT * FROM orders
	WHERE order_date >='2025-03-01'
	AND order_date <= '2025-03-31';


----9). Show all orders with status Shipped---


SELECT * 
		FROM orders
		WHERE status ='Shipped';


----10).Show customers who signed up after 2025-02-01---

SELECT *
FROM customers
WHERE signup_date > '2025-02-01';



---Level 2: Joins + Aggregations (10 Questions)----

---11).Show each order with customer name---
SELECT 
	o.order_id,
	o.order_date,
	o.status,
	c.full_name
FROM orders o
JOIN customers c

ON o.customer_id=c.customer_id;


----12).Show each order item with product name--

SELECT 
  oi.order_item_id,
  oi.order_id,
  p.product_name,
  oi.quantity,
  oi.unit_price
FROM order_items oi
JOIN products p
  ON oi.product_id = p.product_id;


---13). Calculate total amount for each order--

SELECT 
oi.order_id,
SUM(oi.quantity*oi.unit_price) as order_total
FROM order_items oi
GROUP BY order_id
ORDER BY order_id;


-----14).Calculate total spend for each customer---
SELECT 
c.customer_id,
c.full_name,
SUM(oi.quantity*oi.unit_price) as total_spend
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
	JOIN order_items oi
	ON o.order_id=oi.order_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spend DESC;

----15).Find the top spending customer---
SELECT
c.customer_id,
c.full_name,
SUM(oi.quantity*oi.unit_price) as top_spending_customer
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
	JOIN order_items oi
	ON o.order_id= oi.order_id
GROUP BY c.customer_id, c.full_name
ORDER BY top_spending_customer DESC
limit 1;


----16).Category-wise total revenue----

SELECT 
p.category,
SUM(oi.quantity*oi.unit_price) as category_revenue
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.category
ORDER BY category_revenue desc;


 ----17).Product-wise total quantity sold--


SELECT 
p.product_name,
sum(oi.quantity) as total_quantity_sold
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold desc;


----18) List customers who returned an order----

SELECT DISTINCT
c.customer_id,
c.full_name,
o.status
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
WHERE o.status='Returned';


----19) Find customers with no orders (if any)---
SELECT 
c.customer_id,
c.full_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


----20) Find products never sold (if any)---

SELECT 
p.product_id,
p.product_name
FROM products p
LEFT JOIN order_items oi 
ON p.product_id=oi.product_id
WHERE oi.product_id IS NULL;



----Level 3: Advanced Analytics / Window Functions (10 Questions)---


---21) Rank each customer’s orders by date (ROW_NUMBER)--

SELECT 
customer_id,
order_id,
order_date,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS order_rank
FROM orders;


-- Q22: Top spender in each city
WITH customer_spending AS (
  SELECT 
    c.city,
    c.full_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
  FROM customers c
  JOIN orders o
    ON c.customer_id = o.customer_id
  JOIN order_items oi
    ON o.order_id = oi.order_id
  WHERE o.status != 'Cancelled'
  GROUP BY c.city, c.full_name
),
ranked_spenders AS (
  SELECT
    city,
    full_name,
    total_spent,
    DENSE_RANK() OVER (PARTITION BY city ORDER BY total_spent DESC) AS spend_rank
  FROM customer_spending
)
SELECT
  city,
  full_name,
  total_spent
FROM ranked_spenders
WHERE spend_rank = 1;


---23) Find best-selling product in each category---

WITH productsales AS (
SELECT 
p.product_name,
p.category,
SUM(oi.quantity)AS total_unit_sold
FROM products p
JOIN order_items oi 
ON p.product_id=oi.product_id
JOIN orders o
ON o.order_id=oi.order_id
	
WHERE o.status != 'Cancelled'
GROUP BY p.category, p.product_name

),
Rankedproduct  AS (
SELECT 
	category,
	product_name,
	total_unit_sold,
	DENSE_RANK()OVER(PARTITION BY category ORDER BY total_unit_sold DESC) AS sales_rank
	FROM productsales

)
SELECT 
category,
product_name,
total_unit_sold
FROM Rankedproduct
WHERE sales_rank=1;

----24) Rank customers by total spend---
WITH customerTotals AS (
SELECT 
	c.full_name,
	SUM(oi.quantity*oi.unit_price) AS total_spent
	FROM customers c
	JOIN orders o
	ON c.customer_id= o.customer_id
	JOIN order_items oi
	ON o.order_id=oi.order_id
	WHERE o.status != 'Cancelled'
	GROUP BY c.full_name
),
Rankedcustomers AS (
SELECT 
full_name,
total_spent,
DENSE_RANK()OVER(ORDER BY total_spent DESC) AS spend_rank
FROM customerTotals

)

SELECT
	full_name,
	total_spent,
	spend_rank,
CASE
	when spend_rank =1 then 'Platinum'
	when spend_rank <= 3 then 'Gold'
	when spend_rank <=6 then 'Silver'
ELSE  'Bronze'
END  AS customer_tier
FROM Rankedcustomers;
	
----25) Daily revenue trend (date-wise)----


SELECT 
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS daily_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status != 'Cancelled'
GROUP BY o.order_date
ORDER BY o.order_date ASC;


----26) Running total revenue (date-wise)----
WITH dailysales AS (
SELECT 
	o.order_date,
	SUM(oi.quantity*oi.unit_price)AS daily_revenue
	FROM orders o
	JOIN order_items oi
	ON o.order_id=oi.order_id
	WHERE O.status != 'Cancelled'
	GROUP BY o.order_date
)
SELECT
	order_date,
	daily_revenue,
	SUM(daily_revenue)OVER(ORDER BY order_date asc)AS running_total
	FROM dailysales
	ORDER BY order_date;

----27) Find last order date for each customer----
SELECT 
	c.full_name,
	COALESCE(MAX(o.order_date)::TEXT,'No Orders') AS last_order_date
	FROM customers c
	LEFT JOIN orders o
	ON c.customer_id=o.customer_id
	GROUP BY c.full_name
	ORDER BY MAX(o.order_date) DESC;

----28) Calculate average order value---
SELECT
  SUM(oi.quantity * oi.unit_price) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_items oi
  ON o.order_id = oi.order_id
WHERE o.status != 'Cancelled';


----29) Create spend buckets using CASE (High/Medium/Low)----

WITH customerspending AS(
	SELECT 
		c.full_name,
		SUM(oi.quantity*oi.unit_price) AS total_spent
		FROM  customers c
		JOIN orders o
		ON c.customer_id=o.customer_id
		JOIN order_items oi
		ON o.order_id=oi.order_id
		WHERE o.status !='Cancelled'
		GROUP BY c.full_name
)

SELECT 
	full_name,
	total_spent,
	CASE
		when total_spent >10000 THEN 'High'
		when total_spent >=5000 THEN 'Medium'
		ELSE 'Low'
	END  AS spend_bucket

FROM customerspending
ORDER BY total_spent DESC;

----30) Orders where total amount is above average order amount----

SELECT 
	order_id,
	SUM(quantity*unit_price) AS order_total
	FROM order_items
	GROUP BY order_id
	HAVING SUM(quantity*unit_price) >(

SELECT AVG(order_sum)
	FROM (
	SELECT SUM(quantity*unit_price) AS order_sum
	FROM order_items
	GROUP BY order_id
	) AS average_table
)
ORDER BY order_total DESC;








	
	































































































		










































		




