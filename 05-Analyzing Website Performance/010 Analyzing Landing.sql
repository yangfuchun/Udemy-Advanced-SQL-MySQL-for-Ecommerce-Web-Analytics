USE mavenfuzzyfactory; 

SELECT min(created_at), min(website_pageview_id)
FROM website_pageviews 
WHERE pageview_url = '/lander-1';

--  min(created_at), min(website_pageview_id)
-- '2012-06-19 00:35:54', '23504'

CREATE TEMPORARY TABLE lander1_first_pageview
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
    INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
	(website_sessions.created_at < '2012-07-28') 
    AND website_pageviews.website_pageview_id > 23504
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- 
CREATE TEMPORARY TABLE sessions_w_home_lander1_landing_page
SELECT 
	lfp.website_session_id,
    wp.pageview_url
FROM 
	lander1_first_pageview lfp
    LEFT JOIN website_pageviews wp on lfp.min_pageview_id = wp.website_pageview_id
WHERE wp.pageview_url = '/home' OR wp.pageview_url = '/lander-1';

select * from sessions_w_home_lander1_landing_page;

-- sessions_w_home_lander1_landing_page left join with website_pageviews to count the pageviews of each session id
-- limit to only 1 and name it as bounce sessions 
CREATE TEMPORARY TABLE bounced_sessions_lander1_home
SELECT 
	sessions_w_home_lander1_landing_page.website_session_id,
    sessions_w_home_lander1_landing_page.pageview_url,
    COUNT(DISTINCT wp.website_pageview_id) AS bounce_sessions  
FROM 
	sessions_w_home_lander1_landing_page 
    LEFT JOIN website_pageviews wp ON sessions_w_home_lander1_landing_page.website_session_id = wp.website_session_id
GROUP BY 	
	sessions_w_home_lander1_landing_page.website_session_id,
    sessions_w_home_lander1_landing_page.pageview_url
HAVING 
	COUNT(DISTINCT wp.website_pageview_id) = 1;

select * from bounced_sessions_lander1_home;

--
SELECT 
	sessions_w_home_lander1_landing_page.pageview_url,
	COUNT(DISTINCT sessions_w_home_lander1_landing_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounced_sessions_lander1_home.website_session_id) As bounced_session_ids,
    COUNT(DISTINCT bounced_sessions_lander1_home.website_session_id)/COUNT(DISTINCT sessions_w_home_lander1_landing_page.website_session_id) AS bounce_rates
FROM 
	sessions_w_home_lander1_landing_page
    LEFT JOIN bounced_sessions_lander1_home ON sessions_w_home_lander1_landing_page.website_session_id = bounced_sessions_lander1_home.website_session_id
GROUP BY sessions_w_home_lander1_landing_page.pageview_url;
