-- SQL Case Study - Spotify

--Script to create and insert data:
CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

-----------------------------------------------------------------------------------------------------------------------------

-- The activity table shows the app installed and app purchase activities for spotify along with country details.

-- SQL Platform Used: Microsoft SQL Server

-- PROBLEM STATEMENT:

-- 1. Find total active users each day.

SELECT event_date
	,COUNT(DISTINCT user_id) AS total_active_users
FROM activity
GROUP BY event_date;

-- 2. Find total active users each week.

SELECT DATEPART(WEEK, event_date) AS week_number
	,COUNT(DISTINCT user_id) AS total_active_users
FROM activity
GROUP BY DATEPART(WEEK, event_date);

-- 3. Date wise total number of users who made the purchase same day they installed the app.

WITH cte1
AS (
	SELECT event_date
		,user_id
		,COUNT(DISTINCT event_name) AS no_of_events
	FROM activity
	GROUP BY event_date
		,user_id
	)
SELECT event_date
	,COUNT(CASE WHEN no_of_events = 2 THEN user_id ELSE NULL END) AS no_of_users_same_day_purchase
FROM cte1
GROUP BY event_date;

-- 4. Percentage of Paid Users in India, USA and any other country should be tagged as others.

with cte1 as
(select COUNT(1) as total_paid_users
, SUM(case when country = 'India' then 1 else 0 end) as no_of_paid_users_in_india
, SUM(case when country = 'USA' then 1 else 0 end) as no_of_paid_users_in_usa
, SUM(case when country not in ('India', 'USA') then 1 else 0 end) as no_of_paid_users_others
from activity
where event_name = 'app-purchase')
select 'India' as country, no_of_paid_users_in_india * 1.0 / total_paid_users * 100 as percentage_users
from cte1
union all
select 'USA' as country, no_of_paid_users_in_usa * 1.0 / total_paid_users * 100 as percentage_users
from cte1
union all
select 'others' as country, no_of_paid_users_others * 1.0 / total_paid_users * 100 as percentage_users
from cte1;

-- 5. Among all the users who installed the app on a given day, how many did in app puchased on the very next day -- day wise result.

WITH cte1
AS (
	SELECT *
		,LAG(event_name) OVER (PARTITION BY user_id ORDER BY event_date) AS prev_event_name
		,LAG(event_date) OVER (PARTITION BY user_id ORDER BY event_date) AS prev_event_date
	FROM activity
	)
SELECT event_date
	,COUNT(CASE WHEN event_name = 'app-purchase'
				AND prev_event_name = 'app-installed'
				AND DATEDIFF(DAY, prev_event_date, event_date) = 1
				THEN user_id END) AS users_cnt
FROM cte1
GROUP BY event_date;
