
/* 
002 ASSIGNMENT Analyzing Seasonality
take a look at 2012’s monthly and weekly volume patterns to see if we can find any seasonal trends we should plan for in 2013. 
Pull session volume and order volume 
*/

USE mavenfuzzyfactory;

SELECT 	
	YEAR(website_sessions.created_at) AS YR,
	WEEK(website_sessions.created_at) AS WK,
    MIN(DATE(website_sessions.created_at)) AS week_start,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2

