-- Business Context: we want to see landing performance for a certain time period 

-- STEP 1: find the first website_pageview_id for relevant sessions 
-- STEP 2: identify the landing page of each sessions 
-- STEP 3: counting pageviews for each session to identify "bounces"
-- STEP 4: summarizing total sessions and bounced session

USE mavenfuzzyfactory;

-- finding the minimum website pageview id associated with each session we care about 

CREATE TEMPORARY TABLE first_pageview
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
	INNER JOIN
    website_sessions ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at < '2012-06-14'
GROUP BY website_pageviews.website_session_id;

-- bring in the landing page to each session 

CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT 
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview.min_pageview_id -- website page view is the landing page view 
WHERE website_pageviews.pageview_url = '/home';

SELECT * from sessions_w_home_landing_page; -- QA only 

-- create temporary table bounced_sessions only
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    count(website_pageviews.website_pageview_id) as count_of_pages_viewd 
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews 
	ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id 
    -- in this case we are using website session id because one session can have multiple pageviews so we gonna get multiple records coming back 
GROUP BY  
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
Having 
	COUNT(website_pageviews.website_pageview_id) =1;

-- sessions_w_home_landing_page left join bounced_sessions because we do not wanna lose the home landing sessions; we are only 
-- trying to match sessions and bounced sessions     
SELECT 
    sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
LEFT JOIN bounced_sessions 
ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_w_home_landing_page.website_session_id;


-- final output 
 -- use the same query we previously ran and run a count of records 
 -- group by landing page, and add a bounce rate column 
 
SELECT 
	sessions_w_home_landing_page.landing_page,
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page LEFT JOIN bounced_sessions ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
GROUP BY sessions_w_home_landing_page.landing_page