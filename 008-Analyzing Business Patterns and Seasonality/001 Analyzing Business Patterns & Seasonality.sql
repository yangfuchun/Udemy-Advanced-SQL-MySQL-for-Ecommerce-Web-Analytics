USE mavenfuzzyfactory;

SELECT 
	website_session_id, 
	created_at, 
	HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday, -- 0 to 6; 0 = Mon, 1= Tue, etc. 
    CASE 
		WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
        ELSE 'other_day'
	END AS clean_weekday,
    QUARTER(created_at) AS qt
FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000

