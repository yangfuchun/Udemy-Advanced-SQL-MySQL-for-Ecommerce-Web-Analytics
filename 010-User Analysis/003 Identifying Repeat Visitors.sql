/*
003 ASSIGNMENT Identifying Repeat Visitors 
been thinking about customer value based solely on their first session conversion and revenue. 
But if customers have repeat sessions, they maybe more valuable than we thought. 
Pull data on how many of our website visitors come back for another session. 2014 to date is good 
*/


USE mavenfuzzyfactory;

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT  
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    website_sessions.website_session_id AS repeat_session_id
FROM 
(
SELECT user_id, website_session_id
FROM website_sessions
WHERE is_repeat_session = 0 AND created_at >= '2014-01-01' AND created_at < '2014-11-01')
AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.website_session_id > new_sessions.website_session_id
    AND created_at >= '2014-01-01' AND created_at < '2014-11-01';


SELECT
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM 
(
SELECT 
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS user_level

GROUP BY 1;
    