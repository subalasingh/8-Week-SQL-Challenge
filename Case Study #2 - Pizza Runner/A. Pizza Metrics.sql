--A. Pizza Metrics

--1. How many pizzas were ordered?

SELECT COUNT(order_ID) AS pizza_count
FROM updated_customer_orders;

--Result:
+──────────────+
| pizza_count  |
+──────────────+
| 14           |
+──────────────+

--2. How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_ID)) AS unique_order
FROM updated_customer_orders;

--Result:
+──────────────+
| unique_order |
+──────────────+
| 10           |
+──────────────+

--3. How many successful orders were delivered by each runner?

SELECT 
  runner_id, 
  count(order_id) AS successful_orders
FROM updated_runner_orders 
WHERE cancellation = ''
Group BY runner_id;
 
--Result:
+────────────+────────────────────+
| runner_id  | successful_orders  |
+────────────+────────────────────+
| 1          | 4                  |
| 2          | 3                  |
| 3          | 1                  |
+────────────+────────────────────+

--4. How many of each type of pizza was delivered?

SELECT 
  pizza_id, 
  count(updated_customer_orders.order_id) AS delivered_orders
FROM 
  updated_customer_orders JOIN updated_runner_orders
ON
  updated_customer_orders.order_id = updated_runner_orders.order_id
WHERE cancellation = ''
Group BY pizza_id;

--Result:
+──────────+──────────────────+
| pizza_id | delivered_orders |
+──────────+──────────────────+
| 1        | 9                |
| 2        | 3                |
+──────────+──────────────────+

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
  customer_id,
  SUM(CASE Pizza_id WHEN 1 THEN 1 ELSE 0 END) AS meat_lovers,
  SUM(CASE Pizza_id WHEN 2 THEN 1 ELSE 0 END) AS vegetarian
FROM updated_customer_orders
GROUP BY customer_id;

--Result:
+──────────────+──────────────+─────────────+
| customer_id  | meat_lovers  | vegetarian  |
+──────────────+──────────────+─────────────+
| 101          | 2            | 1           |
| 103          | 3            | 1           |
| 104          | 3            | 0           |
| 105          | 0            | 1           |
| 102          | 2            | 1           |
+──────────────+──────────────+─────────────+

--6. What was the maximum number of pizzas delivered in a single order?

SELECT MAX(pizza_delivered) AS max_count
FROM(
	SELECT 
      updated_customer_orders.order_id, 
      count(pizza_id) AS pizza_delivered
    FROM updated_customer_orders JOIN updated_runner_orders
    ON updated_customer_orders.order_id = updated_runner_orders.order_id
    WHERE cancellation = ''
    GROUP BY updated_customer_orders.order_id
) As pizzas;

--Result:
+────────────+
| max_count  |
+────────────+
| 3          |
+────────────+

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT updated_customer_orders.customer_id,
 SUM (CASE WHEN exclusions <> '' OR extras <> '' THEN 1 ELSE 0 END) AS changes,
 SUM (CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_change
FROM updated_customer_orders JOIN updated_runner_orders
ON updated_customer_orders.order_id = updated_runner_orders.order_id
WHERE cancellation = ''
GROUP BY updated_customer_orders.customer_id;

--Result:
+──────────────+──────────+────────────+
| customer_id  | changes  | no_change  |
+──────────────+──────────+────────────+
| 101          | 0        | 2          |
| 102          | 0        | 3          |
| 103          | 3        | 0          |
| 104          | 2        | 1          |
| 105          | 1        | 0          |
+──────────────+──────────+────────────+

--8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
  SUM ( CASE WHEN exclusions <> '' AND extras <> '' THEN 1 ELSE 0 END )AS pizza_count
FROM updated_customer_orders JOIN updated_runner_orders
ON updated_customer_orders.order_id = updated_runner_orders.order_id
WHERE cancellation = '';

--Result:
+──────────────+
| pizza_count  |
+──────────────+
| 1            |
+──────────────+

--9. What was the total volume of pizzas ordered for each hour of the day?

