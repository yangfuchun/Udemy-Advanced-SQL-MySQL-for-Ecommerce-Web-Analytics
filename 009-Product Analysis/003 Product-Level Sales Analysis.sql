/*
003 ASSIGNMENT Product-Level Sales Analysis
about to launch a new product, so wanna dive on the current flagship product. 
Pull monthly trends to date for number of sales, total revenue, and total margin generated for the business 
*/

USE mavenfuzzyfactory;

SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2