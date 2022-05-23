--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Subala singh
--Date: 23/05/2022 
--Tool used: Postgre SQL Server

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?

SELECT 
 customer_id, 
 SUM(price) As total_amount 
FROM sales JOIN menu 
ON sales.product_id = menu.product_id 
GROUP BY customer_id;

--2. How many days has each customer visited the restaurant?

SELECT 
 customer_id, 
 COUNT(DISTINCT(order_date)) AS visited_days
FROM sales
GROUP BY customer_id;

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
 FROM sales JOIN menu
ON sales.product_id = menu.product_id
) 
Select * FROM c_order WHERE item_rank = 1;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

Select 
 product_name,
 COUNT(menu.product_id) AS item_count 
FROM 
sales JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY menu.product_name 
ORDER BY item_count DESC 
LIMIT 1;

--5. Which item was the most popular for each customer?

--------------------------------
--------------------------------
