/* BUSINESS CONTEXT

PetMind is a retailer of products for pets. They are based in the United States.
PetMind sells products that are a mix of luxury items and everyday items. Luxury items include toys. Everyday items include food.
The company wants to increase sales by selling more products for some animals repeatedly.
They have been testing this approach for the last year.
They now want a report on how repeat purchases impact sales.
*/

/*Task 1 CLEANSING DATA 
  Replace missing data to 'Unknown' for category, animal, size
  Replace missing price, rating to 0
  Replace missing sales with median sales
  Remove null values of repeat_purchase
*/

SELECT
  product_id,
  CASE WHEN category = '-' THEN 'Unknown' ELSE category END AS category,
  animal,
  UPPER(LEFT(size, 1)) + LOWER(SUBSTRING(size, 2, LEN(size))) AS size, /* INITCAP(size) AS size in mySQL */
  CASE 
    WHEN LOWER(price) = 'unlisted' THEN 0
    WHEN ISNUMERIC(price) = 1 THEN CAST(price AS DECIMAL(10,2))
    ELSE 0
  END AS price,
  COALESCE(sales, AVG(sales)) AS sales,
  COALESCE(rating, 0) AS rating,
  repeat_purchase
FROM pet_supplies
WHERE repeat_purchase IS NOT NULL
GROUP BY product_id,category,animal,size,price, rating, repeat_purchase,sales

/*Task 2
Testing whether sales are higher for repeat purchases for different animals.
*/

SELECT 
	animal,
 	repeat_purchase,
	ROUND(AVG(sales),0) AS avg_sales,
	ROUND(MIN(sales),0) AS min_sales,
	ROUND(MAX(sales),0) AS max_sales
FROM pet_supplies
GROUP BY animal, repeat_purchase

/*Task 3
The management team want to focus on efforts in the next year on the most popular pets - cats and dogs - for products that are bought repeatedly.
*/
SELECT
product_id,
sales,
rating
FROM pet_supplies
WHERE animal IN ('Cat', 'Dog')
AND repeat_purchase = 1