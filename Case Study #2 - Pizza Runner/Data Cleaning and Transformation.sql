-------------------------------------------------
-----DATA CLEANING AND TABLE TRANSFORMATION------
-------------------------------------------------

---- Datatype check of customer_orders----

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'customer_orders';

--Result:
+──────────────────+──────────────+──────────────────────────────+
| table_name       | column_name  | data_type                    |
+──────────────────+──────────────+──────────────────────────────+
| customer_orders  | order_id     | integer                      |
| customer_orders  | customer_id  | integer                      |
| customer_orders  | pizza_id     | integer                      |
| customer_orders  | exclusions   | character varying            |
| customer_orders  | extras       | character varying            |
| customer_orders  | order_time   | timestamp without time zone  |
+──────────────────+──────────────+──────────────────────────────+

----Datatype check of runner_orders----

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'runner_orders';

--Result:
+────────────────+──────────────+────────────────────+
| table_name     | column_name  | data_type          |
+────────────────+──────────────+────────────────────+
| runner_orders  | order_id     | integer            |
| runner_orders  | runner_id    | integer            |
| runner_orders  | pickup_time  | character varying  |
| runner_orders  | distance     | character varying  |
| runner_orders  | duration     | character varying  |
| runner_orders  | cancellation | character varying  |
+────────────────+──────────────+────────────────────+

--1. customer_order
/*
Cleaning customer_orders
- Identify records with 'null' values
- Updating 'null' values to ''
- Blanks '' indicate that the customer requested no extras/exclusions for the pizza, whereas null values would be ambiguous on this.
*/

DROP TABLE IF EXISTS updated_customer_orders;
CREATE TEMP TABLE updated_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
      WHEN exclusions IS NULL 
        OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
    END AS exclusions,
    CASE 
      WHEN extras IS NULL
        OR extras LIKE 'null' THEN ''
      ELSE extras 
    END AS extras,
    order_time
  FROM pizza_runner.customer_orders
);
SELECT * FROM updated_customer_orders;

--Result:
+───────────+──────────────+───────────+─────────────+─────────+───────────────────────────+
| order_id  | customer_id  | pizza_id  | exclusions  | extras  | order_time                |
+───────────+──────────────+───────────+─────────────+─────────+───────────────────────────+
| 1         | 101          | 1         |             |         | 2020-01-01T18:05:02.000Z  |
| 2         | 101          | 1         |             |         | 2020-01-01T19:00:52.000Z  |
| 3         | 102          | 1         |             |         | 2020-01-02T12:51:23.000Z  |
| 3         | 102          | 2         |             |         | 2020-01-02T12:51:23.000Z  |
| 4         | 103          | 1         | 4           |         | 2020-01-04T13:23:46.000Z  |
| 4         | 103          | 1         | 4           |         | 2020-01-04T13:23:46.000Z  |
| 4         | 103          | 2         | 4           |         | 2020-01-04T13:23:46.000Z  |
| 5         | 104          | 1         |             | 1       | 2020-01-08T21:00:29.000Z  |
| 6         | 101          | 2         |             |         | 2020-01-08T21:03:13.000Z  |
| 7         | 105          | 2         |             | 1       | 2020-01-08T21:20:29.000Z  |
| 8         | 102          | 1         |             |         | 2020-01-09T23:54:33.000Z  |
| 9         | 103          | 1         | 4           | 1, 5    | 2020-01-10T11:22:59.000Z  |
| 10        | 104          | 1         |             |         | 2020-01-11T18:34:49.000Z  |
| 10        | 104          | 1         | 2, 6        | 1, 4    | 2020-01-11T18:34:49.000Z  |
+───────────+──────────────+───────────+─────────────+─────────+───────────────────────────+
