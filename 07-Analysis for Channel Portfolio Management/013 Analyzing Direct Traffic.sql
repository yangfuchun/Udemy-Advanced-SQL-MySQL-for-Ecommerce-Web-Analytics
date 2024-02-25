/*
012 ASSIGNMENT Analyzing Direct Traffic: 
Pull organic search, direct type in and paid brand search sessions by month 
and show those sessions as % of paid search nonbrand 
*/

SELECT

	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic' THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic' THEN website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand
FROM 
(SELECT 
website_session_id,
created_at,
CASE 
	WHEN http_referer IS NULL THEN 'direct_type_in'
    WHEN http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') AND utm_source IS NULL THEN 'organic'
	WHEN utm_campaign = 'brand' THEN 'paid_brand'
	WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'

END AS channel_group

FROM website_sessions
WHERE created_at < '2012-12-23') AS sessions_w_channels
GROUP BY 1, 2;
-- AND utm_source IS NULL -- get rid of paid traffic 
-- http_referer: if null then direct type in (put doman in brower) if not null then organic search 
