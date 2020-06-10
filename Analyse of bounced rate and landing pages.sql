-- finding the minimum pageview id assosiated with each session

create temporary table min_page_
select
website_pageviews.website_session_id,
Min(website_pageviews.website_pageview_id) as min_page
from website_pageviews
inner join website_sessions
on website_pageviews.website_session_id = website_sessions.website_session_id
and website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1;

-- step 2: identify the landing page for each session
create temporary table landing_page_demo
select 
min_page_.website_session_id,
website_pageviews.pageview_url
from min_page_
left join website_pageviews
on min_page_.min_page=website_pageviews.website_pageview_id; -- website_pageview is the landing pageview


-- step 3: counting pageviews for each session to identify bounces
create temporary table bounced_sessions_only
select
landing_page_demo.website_session_id,
landing_page_demo.pageview_url,
Count(website_pageviews.website_pageview_id) as pageviews
from landing_page_demo
left join website_pageviews
on landing_page_demo.website_session_id=website_pageviews.website_session_id
group by 
1,2
having 
pageviews = 1;

-- step 4: sum total sessions and bounced sessions 
select 
landing_page_demo.pageview_url,
Count(distinct landing_page_demo.website_session_id) as total_sessions,
Count(distinct bounced_sessions_only.website_session_id) as bounced_sessions,
Count(distinct bounced_sessions_only.website_session_id)/Count(distinct landing_page_demo.website_session_id) as bounce_rate
from landing_page_demo
left join bounced_sessions_only
on landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
group by 1;



