USE mavenfuzzyfactory;

SELECT MIN(created_at), MIN(website_pageview_id)
FROM website_pageviews
WHERE pageview_url = '/billing-2';
# min(created_at), min(website_pageview_id)
# '2012-09-10 00:13:05', '53550'

-- CREATE A TEMPORARY TABLE 
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT 
	website_session_id,
	MAX(billing_page) AS billing_made_it,
    MAX(billing_2_page) AS billing_2_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    (CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page,
    (CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing_2_page,
    (CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
FROM website_sessions 
LEFT JOIN website_pageviews 
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-11-10' AND website_pageviews.website_pageview_id >= 53550
AND website_pageviews.pageview_url IN ('/billing', '/billing-2', '/thank-you-for-your-order')
) AS temp_table
GROUP BY website_session_id;

SELECT * FROM session_level_made_it_flags;

SELECT 
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS B,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 AND thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS O
FROM session_level_made_it_flags;