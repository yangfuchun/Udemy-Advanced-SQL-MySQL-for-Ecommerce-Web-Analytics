/*
015 ASSIGNMENT Product Portfolio Expansion
On Dec 12th 2013, we launched a third product targeting the birthday gift market (Birthday Bear). 
Run a pre-post analysis comparing the month before vs. the month after, 
in terms of session to order conversion rate, AOV, products per order, and revenue per session 
*/

USE mavenfuzzyfactory;

SELECT 
	CASE
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_BBear'
		WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_BBear'
	END AS time_period,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS avg_order_value,
    SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;