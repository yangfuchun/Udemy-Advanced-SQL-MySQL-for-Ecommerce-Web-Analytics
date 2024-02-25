USE mavenfuzzyfactory;

SELECT 
	primary_product_id,
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin,
    AVG(price_usd) AS aov
FROM orders
WHERE order_id BETWEEN 10000 AND 11000
GROUP BY 1