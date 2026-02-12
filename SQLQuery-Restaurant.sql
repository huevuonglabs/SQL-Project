--OBJECTIVE 1 Explore the items table
-- 1. View the menu_items table and write a query to find the number of items on the menu

SELECT COUNT (menu_item_id)
FROM menu_items

-- 2. What are the least and most expensive items on the menu?
SELECT * FROM menu_items
ORDER BY price

SELECT * FROM menu_items
ORDER BY price DESC

-- 3. How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT COUNT(menu_item_id) 
FROM menu_items
WHERE category = 'Italian'


SELECT TOP 1 item_name, category, price
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC

SELECT *
FROM menu_items
WHERE category = 'Italian'
AND price =
(SELECT MIN(price) FROM menu_items
 WHERE category ='Italian')

-- 4. How many dishes are in each category? What is the average dish price within each category?

SELECT category, COUNT(menu_item_id) AS num_items, AVG(price) AS avg_price
FROM menu_items
GROUP BY category

--OBJECTIVE 2: Explore the orders table
--1 View the order_details table. What is the date range of the table?

SELECT * FROM order_details
ORDER BY order_date

SELECT MIN(order_date), MAX(order_date) FROM order_details

--2 How many orders were made within this date range?
  --How many items were ordered within this date range?

  SELECT COUNT(DISTINCT order_id) 
  FROM order_details

  SELECT COUNT(order_details_id) 
  FROM order_details

--3 Which orders had the most number of items?

SELECT order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC

SELECT TOP 1 order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC

--4 How many orders had more than 12 items?
SELECT order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
HAVING COUNT(order_id) >12

-- OBJECTIVES 3 Analyze customer behavior
--1	Combine the menu_items and order_details tables into a single table
SELECT *
FROM order_details
SELECT *
FROM menu_items

SELECT *
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id

--2 What were the least and most ordered items? What categories were they in?
SELECT item_id, category, COUNT(order_details_id) AS num_items
FROM (
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
) AS join_data
GROUP BY item_id, category
ORDER BY num_items DESC

--3 What were the top 5 orders that spent the most money?
SELECT TOP 5 order_id, SUM(price) AS spend
FROM (
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
) AS join_data
GROUP BY order_id
ORDER BY spend DESC

--4 View the details of the highest spend order. Which specific items were purchased?
SELECT order_id, item_id, item_name, category, price
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
WHERE order_id = 440

--BONUS: View the details of the top 5 highest spend orders
SELECT order_id, category, COUNT (item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
WHERE order_id IN ( 440, 2075, 1957, 330,2675)
GROUP BY order_id, category
ORDER BY order_id, num_items DESC