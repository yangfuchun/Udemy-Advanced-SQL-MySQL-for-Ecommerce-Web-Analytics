/*
learn more about bsearch nonbrand compaign. 
pull percentage of traffic coming on mobile and compare that to gsearch. aggregate data since august 22nd
*/


USE mavenfuzzyfactory;

SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS percentage_sessions
FROM website_sessions

WHERE website_sessions.created_at > '2012-08-22' AND website_sessions.created_at < '2012-11-30' 
AND utm_source IN ('bsearch','gsearch')
AND utm_campaign = 'nonbrand'

GROUP BY utm_source;