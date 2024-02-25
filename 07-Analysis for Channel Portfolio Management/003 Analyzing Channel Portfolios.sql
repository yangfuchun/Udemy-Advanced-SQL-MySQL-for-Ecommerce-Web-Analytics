/*
Assignment: with gsearch doing well, launched a second paid search channel bsearch. 
pull weekly trended session volume since august 22 and compare to gsearch nonbrand 
*/


USE mavenfuzzyfactory;

SELECT 
	YEARWEEK(created_at) AS yrwk,
    MIN(DATE(created_at)) AS start_week,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions

WHERE website_sessions.created_at > '2012-08-22' AND website_sessions.created_at < '2012-11-29'
AND utm_campaign = 'nonbrand'

GROUP BY YEARWEEK(created_at)
