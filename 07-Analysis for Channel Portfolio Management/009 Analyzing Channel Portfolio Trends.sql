/*
009 ASSIGNMENT Analyzing Channel Portfolio Trends: 
bid down bsearch nonbrand on Dec 2nd. Pull weekly volume for gsearch and bsearch nonbrand, broken down by device, since Nov 4th. 
Include a comparison metric to show bsearch as a percent of gsearch for each device 
*/

USE mavenfuzzyfactory;

SELECT 
	YEARWEEK(created_at) AS yrwk,
    MIN(DATE(created_at)) AS start_week,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS gsearch_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop'THEN website_session_id ELSE NULL END) AS bsearch_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop'THEN website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)  AS b_pct_of_g_dtop,
    
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS gsearch_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile'THEN website_session_id ELSE NULL END) AS bsearch_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile'THEN website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)  AS b_pct_of_g_mob
    
FROM website_sessions

WHERE website_sessions.created_at > '2012-11-04' AND website_sessions.created_at < '2012-12-22'
AND utm_campaign = 'nonbrand'

GROUP BY 1