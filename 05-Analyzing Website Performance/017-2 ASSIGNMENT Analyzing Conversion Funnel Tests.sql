USE mavenfuzzyfactory;

SELECT MIN(created_at), MIN(website_pageview_id)
FROM website_pageviews
WHERE pageview_url = '/billing-2';
# min(created_at), min(website_pageview_id)
# '2012-09-10 00:13:05', '53550'


SELECT
	pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) as session_to_orrder_rate
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    orders.order_id
FROM website_pageviews LEFT JOIN orders ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2') 
AND website_pageviews.created_at < '2012-11-10' 
AND website_pageviews.website_pageview_id > 53550
) AS temp_table
GROUP BY pageview_url;
