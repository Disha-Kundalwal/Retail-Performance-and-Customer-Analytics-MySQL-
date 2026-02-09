create database retail;
USE retail;
-- import data using wizard
DESC customer_profiles;
DESC product_inventory;
DESC sales_transaction;
-- fixing primery key of each table having typos error
ALTER TABLE customer_profiles
RENAME COLUMN ï»¿CustomerID TO CustomerID;
ALTER TABLE product_inventory
RENAME COLUMN ï»¿ProductID to ProductID;
ALTER TABLE sales_transaction
RENAME COLUMN ï»¿TransactionID to TransactionID;
SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- Identify and eleminate duplicate records from sales_transaction

SELECT
     TransactionID,
     COUNT(*) AS trxn_count
FROM sales_transaction
GROUP BY 1
HAVING trxn_count > 1;  -- 4999 and 5000 are duplicate

CREATE TABLE sale_trxn_unique AS -- table with unique values without duplicate
SELECT 
     DISTINCT *
FROM sales_transaction;

DROP TABLE sales_transaction;
ALTER TABLE sale_trxn_unique 
RENAME TO sales_transaction;

SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

SELECT 
     s.ProductID,
     s.TransactionID,
     s.Price as TrxnPrice,
     p.Price as InventoryPrice
FROM sales_transaction as s
JOIN product_inventory as p
ON s.ProductID = p.ProductID
WHERE p.Price != s.Price;

SELECT * FROM sales_transaction where ProductID = 51;
UPDATE sales_transaction 
SET Price = 93.12
WHERE ProductID = 51;

USE retail;
SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- finding missing values
SELECT DISTINCT Location FROM customer_profiles;
SELECT Count(Location) FROM customer_profiles where Location is null;
SELECT Count(Location) FROM customer_profiles where Location = "";
-- UPDDATE empty cells with Unknown
UPDATE customer_profiles 
SET Location = "Unknown" WHERE Location="";


DESC sales_transaction;
-- Convert TransactionDate column from text to DATE
CREATE TABLE sales_trxn_backup AS
SELECT *, CAST(TransactionDate as DATE) AS new_trxn_date
FROM sales_transaction;

SELECT * FROM sales_trxn_backup;
DROP TABLE sales_transaction;
ALTER TABLE sales_trxn_backup
RENAME TO sales_transaction;
ALTER TABLE sales_transaction
DROP COLUMN TransactionDate ;
ALTER TABLE sales_transaction
RENAME COLUMN new_trxn_date TO TransactionDate;

-- Analyze which product are generating the most sales and unit sold
SELECT * FROM sales_transaction;
SELECT 
      ProductID, 
      ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales,
      SUM(QuantityPurchased) as TotalUnitSold
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;

-- Identify customers based on how frequently they make purchase
SELECT * FROM sales_transaction;
SELECT 
     CustomerID,
     Count(*) as Transaction_Count
FROM sales_transaction
GROUP BY CustomerID
ORDER BY Transaction_Count DESc;

-- Evaluating which product categories generate the most revenue
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;
SELECT 
      p.Category,
      ROUND(SUM(s.QuantityPurchased * s.Price),0) as TotalRevenue,
      SUM(s.QuantityPurchased) as TotalUnitSold
FROM product_inventory p
JOIN sales_transaction s
ON p.ProductID = s.ProductId
GROUP BY P.Category
Order By TotalRevenue DESC;

-- Identify the top 10 products based on total revenue generated
SELECT 
     ProductID,
     ROUND(SUM(QuantityPurchased * Price),0) as TotalRevenue
	FROM sales_transaction
    GROUP BY ProductID
    ORDER BY TotalRevenue DESC
    LIMIT 10;
    
    -- Find the top 10 products with the lowest unit sold
    SELECT 
     ProductID,
    SUM(QuantityPurchased) as TotalUnitSold
	FROM sales_transaction
    GROUP BY ProductID
    ORDER BY TotalUnitSold ASC
    LIMIT 10;
    
    -- Understanding how daily sales and transaction volume fluctuate over time
    SELECT * FROM sales_transaction;
SELECT 
         CAST(TransactionDate AS DATE) AS DATETRANS,
         COUNT(*) AS Transaction_Count,
         SUM(QuantityPurchased) AS TotalUnitSold,
         ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales
FROM sales_transaction
GROUP BY 1
ORDER BY 1;
    
 -- Analyzing how total monthly sales are growing or declining over time (month on month) 
SELECT * FROM sales_transaction;
WITH Monthly_sales AS (
      SELECT 
           EXTRACT(MONTH FROM TransactionDate) AS Month ,
           ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales
		FROM sales_transaction
        GROUP BY  EXTRACT(MONTH FROM TransactionDate)
 )
  SELECT Month,
  TotalSales,
  LAG(TotalSales) OVER (ORDER BY Month) as previous_month_sales,
  Round(((TotalSales -  LAG(TotalSales) OVER (ORDER BY Month))/
  LAG(TotalSales) OVER (ORDER BY Month))* 100, 2) AS mom_growth_percentage
  FROM Monthly_sales
  ORDER BY month;
  
  -- Identify customers who purchase frequently and spend significantlay
  SELECT 
      CustomerID,
      COUNT(*) AS NumberOfTransactions,
      ROUND(SUM(QuantityPurchased * Price),0) AS TotalSpent
	FROM sales_transaction
    GROUP BY CustomerID
    HAVING TotalSpent > 1000 AND NumberOfTransactions > 10
    ORDER BY TotalSpent DESC;
    
   -- Detect low-frequency, low-spend customer for re-engagement stratergies
     SELECT 
      CustomerID,
      COUNT(*) AS NumberOfTransactions,
      ROUND(SUM(QuantityPurchased * Price),0) AS TotalSpent
	FROM sales_transaction
    GROUP BY CustomerID
    HAVING NumberOfTransactions <=2
    ORDER BY NumberOfTransactions, TotalSpent DESC;
    
    -- Track which customers repeatedly purchased the same product
      SELECT 
      CustomerID,
      ProductID,
      COUNT(*) AS TimePurchased
	FROM sales_transaction
    GROUP BY CustomerID,ProductId
    HAVING TimePurchased > 1
    ORDER BY TimePurchased DESC;
    
-- Measure customer loyalty on time between first and last pirchases
SELECT * FROM sales_transaction;
DESC  sales_transaction;
SELECT 
      CustomerID,
      MIN(TransactionDate) AS FirstPurchase,
	  MAX(TransactionDate) AS LastPurchase,
      DATEDIFF(MAX(TransactionDate),MIN(TransactionDate)) AS DaysBetweenPurchases
      FROM sales_transaction
      GROUP BY 1
      HAVING DaysBetweenPurchases > 0
      ORDER BY DaysBetweenPurchases DESC;
      
-- Group customers into segment based on the total quantity of product by purchased
CREATE TABLE customer_segment AS
SELECT
      CustomerID,
	CASE
           WHEN TotalQty > 30 THEN 'High'
           WHEN TotalQty BETWEEN 11 AND 30 THEN 'Mid'
           WHEN TotalQty BETWEEN 1 AND 10 THEN 'Low'
		END AS CustomerSegment
FROM (
       SELECT 
             c.CustomerID,
             SUM(s.QuantityPurchased) AS TotalQty
             FROM customer_profiles c
		JOIN sales_transaction s
        ON c.CustomerID = s.CustomerID
        GROup by c.CustomerID
	) AS customer_total;
SELECT * FROM customer_segment ;
           
      
      
      
      
      
      
      
      
      