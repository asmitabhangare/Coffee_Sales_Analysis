create database coffee;

use coffee;

update coffee
set transaction_date = str_to_date(transaction_date,'%d-%m-%Y');

ALTER TABLE coffee
MODIFY COLUMN transaction_date DATE;

describe coffee.coffee;

update coffee
set transaction_time = str_to_date(transaction_time,'%H:%i:%s');

ALTER TABLE coffee
MODIFY COLUMN transaction_time TIME;

SELECT * FROM coffee.coffee;

-- TOTAL SALES
-- Calculate total Sales for each month
SELECT MONTH(transaction_date) AS month_, CONCAT(ROUND(SUM(transaction_qty*unit_price),0),"K") AS Total_Sales
FROM coffee.coffee
GROUP BY month_;

-- Determine month-on month incresed or decresed sales
SELECT
	MONTH(transaction_date) AS month,
	ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
	OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee.coffee
WHERE
	MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
-- TOTAL ORDERS
-- Calculate total Orders for each month
SELECT MONTH(transaction_date) AS month_, COUNT(transaction_id) AS Total_Orders
FROM coffee.coffee
GROUP BY month_;

-- Determine month-on month incresed or decresed orders
SELECT
	MONTH(transaction_date) AS month,
	COUNT(transaction_id) AS total_orders,
	(COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)
	OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1)
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee.coffee
WHERE
	MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
-- TOTAL QUANTITY SOLD
-- Calculate total Qantity Sold for each month
SELECT MONTH(transaction_date) AS month_, SUM(transaction_qty) AS Total_Quantity
FROM coffee.coffee
GROUP BY month_;

-- Determine month-on month incresed or decresed quantity
SELECT
	MONTH(transaction_date) AS month,
	SUM(transaction_qty) AS total_qty,
	(SUM(transaction_qty) - LAG(SUM(transaction_qty), 1)
	OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1)
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee.coffee
WHERE
	MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
	CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),"K") AS total_sales,
	CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),"K") AS total_orders,
	CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),"K") AS total_quantity_sold
FROM coffee.coffee
WHERE
	transaction_date = '2023-05-18';

-- SALES BY WEEKDAY / WEEKEND:    
SELECT
	CASE WHEN DAYOFWEEK(transaction_date) IN(1,7) THEN "Weekends"
    ELSE "Weekdays"
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty),0),"K") AS Total_Sales
FROM coffee.coffee
WHERE MONTH(transaction_date) = 5
GROUP BY day_type;

-- SALES BY STORE LOCATION
SELECT store_location, CONCAT(ROUND(SUM(transaction_qty*unit_price),0),"K") AS Total_Sales
FROM coffee.coffee
WHERE MONTH(transaction_date) = 5
GROUP BY store_location;

-- SALES BY PRODUCT CATEGORY
SELECT product_category, CONCAT(ROUND(SUM(transaction_qty*unit_price),0),"K") AS Total_Sales
FROM coffee.coffee
WHERE MONTH(transaction_date) = 5
GROUP BY product_category;

-- SALES TREND OVER PERIOD
SELECT CONCAT(ROUND(AVG(total_sales),0),'K') AS Avg_Sales
FROM(
	SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee.coffee
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
    ) AS inner_query;
    
-- DAILY SALES FOR MONTH SELECTED
SELECT
	DAY(transaction_date) AS day_of_month,
	ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM coffee.coffee
WHERE
	MONTH(transaction_date) = 5 -- Filter for May
GROUP BY
	DAY(transaction_date)
ORDER BY
	DAY(transaction_date);
    
-- SALES BY PRODUCTS (TOP 10)
SELECT
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee.coffee
WHERE
	MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

-- SALES BY DAY | HOUR
SELECT
	ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
	SUM(transaction_qty) AS Total_Quantity,
	COUNT(*) AS Total_Orders
FROM coffee.coffee
WHERE
DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
AND HOUR(transaction_time) = 8 -- Filter for hour number 8
AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT
	CASE
	WHEN DAYOFWEEK(transaction_date) = 2 THEN "Monday"
	WHEN DAYOFWEEK(transaction_date) = 3 THEN "Tuesday"
	WHEN DAYOFWEEK(transaction_date) = 4 THEN "Wednesday"
	WHEN DAYOFWEEK(transaction_date) = 5 THEN "Thursday"
	WHEN DAYOFWEEK(transaction_date) = 6 THEN "Friday"
	WHEN DAYOFWEEK(transaction_date) = 7 THEN "Saturday"
	ELSE "Sunday"
	END AS Day_of_Week,
	ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee.coffee
WHERE
MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY
	CASE
	WHEN DAYOFWEEK(transaction_date) = 2 THEN "Monday"
	WHEN DAYOFWEEK(transaction_date) = 3 THEN "Tuesday"
	WHEN DAYOFWEEK(transaction_date) = 4 THEN "Wednesday"
	WHEN DAYOFWEEK(transaction_date) = 5 THEN "Thursday"
	WHEN DAYOFWEEK(transaction_date) = 6 THEN "Friday"
	WHEN DAYOFWEEK(transaction_date) = 7 THEN "Saturday"
	ELSE "Sunday"
    END;
    
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT
	HOUR(transaction_time) AS Hour_of_Day,
	ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee.coffee
WHERE
	MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY
	HOUR(transaction_time)
ORDER BY
	Total_Sales DESC;