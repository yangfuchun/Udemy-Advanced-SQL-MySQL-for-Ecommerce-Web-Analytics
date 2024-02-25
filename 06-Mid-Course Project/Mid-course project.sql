USE mavenfuzzyfactory;

/*
1. Objective: 
Gsearch seems to be the biggest driver of the whole business. 
Pull monthly trends for gsearch sessions and orders to showcase the growth there.
*/

SELECT 
	years,
	months,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
FROM(
SELECT 
	website_sessions.website_session_id,
    YEAR(website_sessions.created_at) AS years,
    MONTH(website_sessions.created_at) AS months,
    orders.order_id
FROM website_sessions LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
AND website_sessions.created_at <'2012-11-27') AS temp_table
GROUP BY 1,2;


/*
2. Objective: 
Pull monthly trends for gsearch sessions and orders to showcase the growth. 
This time splitting out nonbrand and brand campaigns separately.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.created_at <'2012-11-27'
GROUP BY 1,2;


/*
3. Objective: 
Gsearch, nonbrand, pull monthly sessions and orders split by device type. 
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders
FROM website_sessions LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND utm_campaign = 'nonbrand'
	AND website_sessions.created_at <'2012-11-27'
GROUP BY 1,2;

/*
4. Objective: 
Large % of traffic from gsearch. 
Pull monthly trends for gsearch, alongside monthly trends for each of other channels.
*/

SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at <'2012-11-27';

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN orders.order_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at <'2012-11-27'
GROUP BY 1,2;

/*
5. Objective: 
Tell the story of the website performance improvements over the course of the first 8 months. 
Pull session to order conversion rates, by months
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_rates
FROM website_sessions LEFT JOIN orders on website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at <'2012-11-27'
GROUP BY 1,2;


/*
6. Objective: 
For the gsearch lander test, estimate the revenue that test earned the company (look at the increase in CVR from the test Jun19-Jul28).
Use nonbrand sessions and revenue since then to calculate incremental value.
*/

-- select session ids and landing pageview id 
CREATE TEMPORARY TABLE first_pageviews
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
    INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
	(website_sessions.created_at < '2012-07-28' AND website_sessions.created_at > '2012-06-19') 
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- add landing page to the table 
CREATE TEMPORARY TABLE sessions_w_home_lander1_landing_page
SELECT 
	first_pageviews.website_session_id,
    website_pageviews.pageview_url
FROM 
	first_pageviews
    LEFT JOIN website_pageviews on first_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/home' OR website_pageviews.pageview_url = '/lander-1';

SELECT * FROM sessions_w_home_lander1_landing_page; -- QA CHECK  

-- left join with orders to have order id information 
CREATE TEMPORARY TABLE sessions_urls_orders
SELECT
	sessions_w_home_lander1_landing_page.website_session_id,
    sessions_w_home_lander1_landing_page.pageview_url,
    orders.order_id
FROM sessions_w_home_lander1_landing_page 
LEFT JOIN orders 
ON sessions_w_home_lander1_landing_page.website_session_id = orders.website_session_id;

-- count session ids, order ids, and calculate session to order conversion rates 
SELECT 
	pageview_url,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS session_to_order_CVR
FROM sessions_urls_orders
GROUP BY pageview_url;



/*
7. Objective: 
For the landing page test analyzed previously, show a full conversion funnel from each of the two pages to orders. 
Use the time period Jun19 - Jul28
*/

CREATE TEMPORARY TABLE sessions_level_made_it_flagged
SELECT 
	website_session_id,
    MAX(home_page) AS entry_home,
    MAX(lander_page) AS entry_lander,
	MAX(products_page) AS product_made_it,
	MAX(mrfuzzy_page) AS mrfuzzy_made_it,
	MAX(cart_page) AS cart_made_it,
	MAX(shipping_page) AS shipping_made_it,
	MAX(billing_page) AS billing_made_it,
	MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28' 
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.utm_source = 'gsearch'
AND website_pageviews.pageview_url IN 
('/home', '/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id;

SELECT 
	CASE 
		WHEN entry_home = 1 THEN 'entry_homepage' 
		WHEN entry_lander = 1 THEN 'entry_lander-1'
		ELSE NULL 
	END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM sessions_level_made_it_flagged
GROUP BY 1;

/*
8. Objective: 
Quantify the impact of billing test and analyze the lift generated from the test (Sep10 - Nov10) in terms of revenue per billing page session.
Pull the number of billing page sessions for the past month to understand monthly impact.
*/

SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews LEFT JOIN orders ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2') 
AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10' 
) AS billing_pageviews_and_order_data
GROUP BY 1;