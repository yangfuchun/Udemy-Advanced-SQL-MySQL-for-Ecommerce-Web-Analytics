/* 
004 ASSIGNMENT Analyzing Business Patterns
considering adding live chat support to the website to improve the customer experience. 
Analyze the average website session volume by hour of day and by day week. 
so we can staff appropriately. date range sep 15 - nov 15 2012
*/

USE mavenfuzzyfactory;

SELECT
	HR,
	AVG(CASE WHEN wkday = 0 THEN sessions ELSE NULL END) AS Mon_session_volume,
	AVG(CASE WHEN wkday = 1 THEN sessions ELSE NULL END) AS Tue_session_volume,
	AVG(CASE WHEN wkday = 2 THEN sessions ELSE NULL END) AS Wed_session_volume,
	AVG(CASE WHEN wkday = 3 THEN sessions ELSE NULL END) AS Thu_session_volume,
    AVG(CASE WHEN wkday = 4 THEN sessions ELSE NULL END) AS Fri_session_volume,
    AVG(CASE WHEN wkday = 5 THEN sessions ELSE NULL END) AS Sat_session_volume,
    AVG(CASE WHEN wkday = 6 THEN sessions ELSE NULL END) AS Sun_session_volume
FROM(
SELECT 	
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
	HOUR(website_sessions.created_at) AS HR,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM website_sessions 
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) 
AS daily_hourly_sessions
GROUP BY 1
