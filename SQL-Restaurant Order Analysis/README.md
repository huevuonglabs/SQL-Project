# 🍽️ Restaurant Orders — Menu + Customer Behavior Analysis (SQL)

## 📌 Project Overview

This project analyzes restaurant ordering behavior using SQL to understand **menu pricing**, **item popularity**, and **high-value customer orders**. The work combines menu data with transaction-level order records to uncover insights that support decisions like **menu optimization, promotions, and revenue strategy**.

---

## 🧩 Business Problem

Restaurant transaction data is only useful if it can answer clear questions like:
**What sells, what earns the most, and what customers actually order together?**

---

## 🛠️ Approach (SQL Workflow)

I explored and analyzed the data in 3 stages:

✅ **Objective 1:** Understand menu size + pricing structure

✅ **Objective 2:** Measure order volume and order size patterns

✅ **Objective 3:** Join menu + orders to identify item demand and revenue-driving orders

---

## ✅ OBJECTIVE 1: Explore Menu Pricing & Structure

### Step 1) Count the number of menu items

```sql
---View the menu_items table and write a query to find the number of items on the menu

SELECT COUNT (menu_item_id)
FROM menu_items
```

---

### Step 2) Identify least vs most expensive menu items

```sql
---What are the least expensive items on the menu?
SELECT * FROM menu_items
ORDER BY price ASC

---What are the most expensive items on the menu?
SELECT * FROM menu_items
ORDER BY price DESC
```

---

### Step 3) Analyze Italian menu items (count + price range)

```sql
--How many Italian dishes are on the menu?
SELECT COUNT(menu_item_id) 
FROM menu_items
WHERE category = 'Italian'

--What are the most expensive Italian dishes on the menu?
SELECT TOP 1 item_name, category, price
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC

--What are the least expensive Italian dishes on the menu?
SELECT *
FROM menu_items
WHERE category = 'Italian'
AND price =
(SELECT MIN(price) FROM menu_items
 WHERE category ='Italian')
```

---

### Step 4) Category breakdown + average price by category

```sql
--How many dishes are in each category? What is the average dish price within each category?

SELECT category, COUNT(menu_item_id) AS num_items, AVG(price) AS avg_price
FROM menu_items
GROUP BY category
```

---

## ✅ OBJECTIVE 2: Explore Orders Table (Volume + Order Size)

### Step 5) Identify the date range of orders

```sql
--View the order_details table. What is the date range of the table?

SELECT * FROM order_details
ORDER BY order_date

SELECT MIN(order_date), MAX(order_date) FROM order_details
```

---

### Step 6) Count total orders + total items ordered

```sql
--How many orders were made within this date range?
--How many items were ordered within this date range?

  SELECT COUNT(DISTINCT order_id) AS total_orders
  FROM order_details

  SELECT COUNT(order_details_id) AS total_items
  FROM order_details
```

---

### Step 7) Find orders with the most items

```sql
--Which orders had the most number of items?
--Option1:
SELECT order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC

--Option2:
SELECT TOP 1 order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC
```

---

### Step 8) Identify orders with more than 12 items

```sql
--How many orders had more than 12 items?
SELECT order_id, COUNT(order_id) AS num_items
FROM order_details
GROUP BY order_id
HAVING COUNT(order_id) >12
```

---

## ✅ OBJECTIVE 3: Customer Behavior + Revenue Analysis

### Step 9) Join menu items with order details

```sql
--Combine the menu_items and order_details tables into a single table
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
```

---

### Step 10) Find least and most ordered items + categories

```sql
--What were the least and most ordered items?
--What categories were they in?
SELECT item_id, category, COUNT(order_details_id) AS num_items
FROM (
  SELECT *
  FROM order_details od
  LEFT JOIN menu_items mi
  ON od.item_id=mi.menu_item_id
  ) AS join_data
GROUP BY item_id, category
ORDER BY num_items DESC
```

---

### Step 11) Identify the top 5 highest-spend orders

```sql
--What were the top 5 orders that spent the most money?
SELECT TOP 5 order_id, SUM(price) AS spend
FROM (
  SELECT *
  FROM order_details od
  LEFT JOIN menu_items mi
  ON od.item_id=mi.menu_item_id
  ) AS join_data
GROUP BY order_id
ORDER BY spend DESC
```

---

### Step 12) Drill into the highest spend order (items purchased)

```sql
--View the details of the highest spend order. Which specific items were purchased?
SELECT order_id, item_id, item_name, category, price
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
WHERE order_id = 440
```

---

### Step 13) Category breakdown of the top 5 highest-spend orders

```sql
--View the details of the top 5 highest spend orders
SELECT order_id, category, COUNT (item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
ON od.item_id=mi.menu_item_id
WHERE order_id IN ( 440, 2075, 1957, 330,2675)
GROUP BY order_id, category
ORDER BY order_id, num_items DESC
```

---

## 🎯 Impact

This project supports decisions like:

**Menu Engineering**

* promote high-demand items
* identify low-performing dishes for improvement or removal

**Revenue Growth**

* understand what drives high-spend orders
* design bundles and upsells based on purchase patterns

**Operational Planning**

* spot large orders (12+ items) that affect prep and staffing

**Reusable Reporting**

* provides clean SQL logic that can be adapted into KPI tracking queries

---

## 🛠 Tools / SQL Concepts Used

* `COUNT()`, `AVG()`, `SUM()`
* `GROUP BY`, `ORDER BY`
* `TOP N`
* `WHERE`, `HAVING`, `WHERE IN`
* `LEFT JOIN`
* Subqueries
* Drill-down order analysis

---
