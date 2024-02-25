/*
010 ASSIGNMENT Building Product-Level Conversion Funnels
look at two products since Jan 6th and analyze the conversion funnels from each product page to conversion. 
Produce a comparison between the two conversion funnels for all website traffic 
*/

USE mavenfuzzyfactory;

CREATE TEMPORARY TABLE sessions_seeing_product_page 
SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

SELECT DISTINCT 
	website_pageviews.pageview_url
FROM sessions_seeing_product_page LEFT JOIN website_pageviews ON sessions_seeing_product_page.website_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > sessions_seeing_product_page.website_pageview_id;


CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'check logic'
	END AS product_seen,
	MAX(cart_page) AS cart_made_it,
	MAX(shipping_page) AS shipping_made_it,
	MAX(billing_page) AS billing_made_it,
	MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	sessions_seeing_product_page.website_session_id,
	sessions_seeing_product_page.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_page
	LEFT JOIN website_pageviews
    ON sessions_seeing_product_page.website_session_id = website_pageviews.website_session_id
    AND website_pageviews.website_pageview_id > sessions_seeing_product_page.website_pageview_id
ORDER BY 
	sessions_seeing_product_page.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY 1,2;


SELECT
	product_seen,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_product_level_made_it_flags
GROUP BY product_seen;


-- translate those counts to click rates for final output part 2 (click rates)
SELECT
	product_seen,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT website_session_id) AS products_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough_rate,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_clickthrough_rate
FROM session_product_level_made_it_flags
GROUP BY product_seen;
