--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Subala singh
--Date: 23/05/2022 
--Tool used: Postgre SQL Server

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?

SELECT 
 customer_id, 
 SUM(price) As total_amount 
FROM dannys_diner.sales JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id 
GROUP BY customer_id;

--Result:
+──────────────+──────────────+
| customer_id  | total_spent  |
+──────────────+──────────────+
| A            | 76           |
| B            | 74           |
| C            | 36           |
+──────────────+──────────────+            

--2. How many days has each customer visited the restaurant?

SELECT 
 customer_id, 
 COUNT(DISTINCT(order_date)) AS visited_days
FROM dannys_diner.sales
GROUP BY customer_id;

--Result:
+──────────────+───────────────+
| customer_id  | visited_days  |
+──────────────+───────────────+
| A            | 4             |
| B            | 6             |
| C            | 2             |
+──────────────+───────────────+

--3. What was the first item from the menu purchased by each customer?

WITH c_order As
(SELECT 
 customer_id, 
 product_name,
 ROW_NUMBER() OVER(
	 partition BY customer_id 
	  ORDER BY 
	   order_date, 
	   sales.product_id
  ) AS item_rank  
 FROM dannys_diner.sales JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
) 
Select * FROM c_order WHERE item_rank = 1;

--Result:
+──────────────+───────────────+─────────────+
| customer_id  | product_name  | item_order  |
+──────────────+───────────────+─────────────+
| A            | sushi         | 1           |
| B            | curry         | 1           |
| C            | ramen         | 1           |
+──────────────+───────────────+─────────────+

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

Select 
 product_name,
 COUNT(menu.product_id) AS item_count 
FROM 
dannys_diner.sales JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
GROUP BY menu.product_name 
ORDER BY item_count DESC 
LIMIT 1;

--Result:
+─────────────+───────────────+──────────────+
| product_id  | product_name  | order_count  |
+─────────────+───────────────+──────────────+
| 3           | ramen         | 8            |
+─────────────+───────────────+──────────────+

--5. Which item was the most popular for each customer?

WITH Cust_order_count AS (SELECT 
 customer_id, 
 product_name, 
 COUNT(sales.product_id)as order_count,
 DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(customer_id) DESC ) AS item_rank
FROM 
 dannys_diner.sales JOIN dannys_diner.menu 
ON 
 sales.product_id = menu.product_id
GROUP BY
 customer_id, product_name
)
SELECT 
 customer_id, 
 product_name, 
 order_count
FROM Cust_order_count
WHERE item_rank = 1;

--Result:
+──────────────+───────────────+──────────────+───────+
| customer_id  | product_name  | order_count  | rank  |
+──────────────+───────────────+──────────────+───────+
| A            | ramen         | 3            | 1     |
| B            | ramen         | 2            | 1     |
| B            | curry         | 2            | 1     |
| B            | sushi         | 2            | 1     |
| C            | ramen         | 3            | 1     |
+──────────────+───────────────+──────────────+───────+

--6. Which item was purchased first by the customer after they became a member?

WITH cust_Purchase AS (
	SELECT 
      sales.customer_id,
      order_date, 
      Product_name,
      ROW_NUMBER() OVER(
		  PARTITION BY sales.customer_id 
		  ORDER BY order_date ASC) as purchase_order
    FROM (
		dannys_diner.sales 
        JOIN 
        dannys_diner.members
        ON
        sales.customer_id = members.customer_id
	)
	JOIN  
	dannys_diner.menu 
	ON sales.product_id = menu.product_id 
	WHERE order_date >= join_date
)
SELECT * FROM cust_Purchase WHERE purchase_order =1;

--Result:
+──────────────+───────────────+───────────────────────────+─────────────────+
| customer_id  | product_name  | order_date                | purchase_order  |
+──────────────+───────────────+───────────────────────────+─────────────────+
| A            | curry         | 2021-01-07T00:00:00.000Z  | 1               |
| B            | sushi         | 2021-01-11T00:00:00.000Z  | 1               |
+──────────────+───────────────+───────────────────────────+─────────────────+

-- 7. Which item was purchased just before the customer became a member?
