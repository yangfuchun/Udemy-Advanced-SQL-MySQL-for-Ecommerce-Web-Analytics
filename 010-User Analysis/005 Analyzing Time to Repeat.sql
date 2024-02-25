/*
005 Analyzing Time to Repeat
help understand the min max and average time between the first and second session for customers who do come back
*/





USE mavenfuzzyfactory;

-- CREATE TEMPORARY TABLE sessions_w_repeats_time_diff
SELECT
	new_sessions.user_id,
    new_sessions.website_session_id,
    new_sessions.created_at,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_created_at
FROM 
(	
SELECT 
	user_id,
	website_session_id,
    created_at
FROM website_sessions
WHERE created_at >= '2014-01-01' AND created_at < '2014-11-03'
AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.is_repeat_session = 1
    AND website_sessions.website_session_id > new_sessions.website_session_id
    AND website_sessions.created_at >= '2014-01-01' AND website_sessions.created_at < '2014-11-03';
    
SELECT * FROM sessions_w_repeats_time_diff;

SELECT 
	user_id,
    COUNT(DISTINCT user_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions,
    datediff(repeat_session_created_at, created_at)
FROM sessions_w_repeats_time_diff
GROUP BY 1,4
ORDER BY 3 DESC