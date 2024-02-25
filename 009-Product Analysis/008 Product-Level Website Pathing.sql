/*
008 ASSIGNMENT Product-Level Website Pathing
lets look at sessions which hit the /products page and see where they went next; 
please pull clickthrough rates from /products since the new product launch on Jan 6th 2013 by product 
and compare to the 3 months leading up to launch as a baseline 
*/

-- STEP 1: find the relevant /products pageviews with website_session_id
-- STEP 2: find the next pageview id that occurs after the product pageview 
-- STEP 3: find the pageview_url associated with any applicable next pageview_id 
-- STEP 4: summarize the data and analyze the pre vs post periods 



-- STEP 1: find the relevant /products pageviews with website_session_id
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_pageview_id,
    website_session_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_product_2'
        WHEN created_at >= '2013-01-06' THEN 'B. Post_product_2'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
AND pageview_url = '/products';


-- STEP 2: find the next pageview id that occurs after the product pageview 
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews LEFT JOIN website_pageviews ON products_pageviews.website_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1,2;

-- STEP 3: find the pageview_url associated with any applicable next pageview_id 
CREATE TEMPORARY TABLE session_w_next_pageview_urls
SELECT 
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id LEFT JOIN website_pageviews 
ON sessions_w_next_pageview_id.min_next_pageview_id = website_pageviews.website_pageview_id;

SELECT * FROM session_w_next_pageview_urls;

-- STEP 4: summarize the data and analyze the pre vs post periods 
SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM session_w_next_pageview_urls
GROUP BY 1;