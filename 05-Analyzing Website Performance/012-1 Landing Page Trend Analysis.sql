/* 
Data do not fully match the data on videos 
*/

USE mavenfuzzyfactory; 

CREATE TEMPORARY TABLE TA_first_pageview
SELECT 
	website_pageviews.created_at,
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
    INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
	(website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31') 
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id,
    website_pageviews.created_at;

    
select * from TA_first_pageview;
-- 
CREATE TEMPORARY TABLE TA_sessions_landing_page
SELECT 
	TA_first_pageview.created_at,
    TA_first_pageview.website_session_id,
    wp.pageview_url
FROM 
	TA_first_pageview
    LEFT JOIN website_pageviews wp on TA_first_pageview.min_pageview_id = wp.website_pageview_id
WHERE wp.pageview_url = '/home' OR wp.pageview_url = '/lander-1';

select * from TA_sessions_landing_page;

-- sessions_w_home_lander1_landing_page left join with website_pageviews to count the pageviews of each session id
-- limit to only 1 and name it as bounce sessions 
CREATE TEMPORARY TABLE TA_bounced_session
SELECT 
	TA_sessions_landing_page.website_session_id,
    TA_sessions_landing_page.pageview_url,
    COUNT(DISTINCT wp.website_pageview_id) AS bounce_sessions  
FROM 
	TA_sessions_landing_page 
    LEFT JOIN website_pageviews wp ON TA_sessions_landing_page.website_session_id = wp.website_session_id
GROUP BY 	
	TA_sessions_landing_page.website_session_id,
    TA_sessions_landing_page.pageview_url
HAVING 
	COUNT(DISTINCT wp.website_pageview_id) = 1;

SELECT * FROM TA_bounced_session;

--
SELECT 
	YEARWEEK(TA_sessions_landing_page.created_at),
	MIN(DATE(TA_sessions_landing_page.created_at)) AS week_start_date,
	COUNT(DISTINCT TA_sessions_landing_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT TA_bounced_session.website_session_id) As bounced_session_ids,
    COUNT(DISTINCT TA_bounced_session.website_session_id)/COUNT(DISTINCT TA_sessions_landing_page.website_session_id) AS bounce_rates,
	COUNT(DISTINCT CASE WHEN TA_sessions_landing_page.pageview_url = '/home' THEN TA_sessions_landing_page.website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN TA_sessions_landing_page.pageview_url = '/lander-1' THEN TA_sessions_landing_page.website_session_id ELSE NULL END) AS lander_sessions

FROM 
	TA_sessions_landing_page
    LEFT JOIN TA_bounced_session ON TA_sessions_landing_page.website_session_id = TA_bounced_session.website_session_id
GROUP BY YEARWEEK(TA_sessions_landing_page.created_at)
