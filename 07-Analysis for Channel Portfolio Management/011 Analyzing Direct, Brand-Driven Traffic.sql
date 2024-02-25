SELECT 
CASE 
	WHEN http_referer IS NULL THEN 'direct_type_in'
    WHEN http_referer = 'https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic'
	WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
    ELSE 'other'
END,
COUNT(DISTINCT website_session_id) AS sessions

FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000 
-- AND utm_source IS NULL -- get rid of paid traffic 
-- http_referer: if null then direct type in (put doman in brower) if not null then organic search 
GROUP BY 1 
ORDER BY 2 DESC;