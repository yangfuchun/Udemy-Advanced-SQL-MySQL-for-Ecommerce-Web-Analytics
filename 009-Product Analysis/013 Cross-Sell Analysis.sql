/* 013 ASSIGNMENT Cross-Sell Analysis - on Sep 25th we started giving customers the option to add a 2nd product while on the /cart page. 
Compare the month before vs the month after the change. CTR (clickthrough rate) from the /cart page, avg products per order, AOV and overall revenue per /cart page view 
*/

-- STEP 1: Identify the relevant /cart page views and their sessions
-- STEP 2: See which of those /cart sessions clicked through to the shipping page 
-- STEP 3: Find the orders associated with the /cart sessions. Analyze products purchased, AVO 
-- STEP 4: Aggregate and analyze a summary of our findings 


USE mavenfuzzyfactory;

-- 
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT 
	website_pageview_id AS cart_pageview_id,
    website_session_id AS cart_session_id,
    CASE
		WHEN created_at < '2013-09-25' THEN 'Pre_cross_sell'
        WHEN created_at > '2013-09-25' THEN 'Post_cross_sell'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
AND pageview_url = '/cart';

SELECT * FROM sessions_seeing_cart;

-- 
CREATE TEMPORARY TABLE cart_sessions_seeing_another_page 
SELECT 
	sessions_seeing_cart.time_period, 
	sessions_seeing_cart.cart_session_id, 
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart LEFT JOIN website_pageviews
ON sessions_seeing_cart.cart_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 1,2
HAVING 
	MIN(website_pageviews.website_pageview_id) IS NOT NULL;

SELECT * FROM cart_sessions_seeing_another_page;
-- 
CREATE TEMPORARY TABLE pre_post_sessions_orders 
SELECT
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM sessions_seeing_cart INNER JOIN orders ON sessions_seeing_cart.cart_session_id = orders.website_session_id;

SELECT * FROM pre_post_sessions_orders;

--

SELECT 
	time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthrough,
    SUM(clicked_to_another_page)/COUNT(DISTINCT cart_session_id) AS cart_ctr,
    SUM(placed_order) AS orders_placed,
    SUM(items_purchased) AS products_purchased,
    SUM(items_purchased)/SUM(placed_order) AS products_per_order,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
FROM(
SELECT 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.pv_id_after_cart IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart LEFT JOIN cart_sessions_seeing_another_page ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
LEFT JOIN pre_post_sessions_orders ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY cart_session_id) AS full_data
GROUP BY time_period;
