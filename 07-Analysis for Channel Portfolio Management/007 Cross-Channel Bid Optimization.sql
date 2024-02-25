/* 
007 ASSIGNMENT Cross-Channel Bid Optimization: wondering if bsaerch nonbrand should have the same bids as gsearch. 
pull nonbrand conversion rates from session to order for gsearch and bsearch and slice the data by device type. 
*/

USE mavenfuzzyfactory;

SELECT 
	utm_source,
    device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM website_sessions
	LEFT JOIN orders -- we want to count all the sessions so we have to left join 
    ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
AND utm_source IN ('gsearch', 'bsearch')

GROUP BY 1,2
