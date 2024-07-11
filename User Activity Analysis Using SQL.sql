/* SQL Portfolio project - User Activity Analysis Using SQL 
Project Overview:
This project focuses on analyzing user activity data from two tables, 'users' and 'logins'. The goal is to 
provide valuable insights into user engagement, activity patterns, and overall usage trends over time. 
write 4-6 queries to explore the dataset and solve below questions. 

1. Which users did not log in during the past 5 months? 
return: username.
2. How many users and sessions were there in each quarter, ordered from newest to oldest?
return: first_day_of_quarter, no_of_users, no_of_sessions
3. Which users logged in during January 2024 but did not log in during November 2023?
return: user_id
4. What is the percentage change in sessions from the last quarter?
return: first_day_of_quarter, no_of_users, no_of_sessions, sessions_cnt_prev, session_percent_change
5. Which user had the highest session score each day?
return: login_date, userid, score
6. Which users had a session every single day since their first login?
return: user_id
7. On what dates there were no logins at all?
return: login_date 

Script to create and insert data:
CREATE TABLE users (
    USER_ID INT PRIMARY KEY,
    USER_NAME VARCHAR(20) NOT NULL,
    USER_STATUS VARCHAR(20) NOT NULL
);

CREATE TABLE logins (
    USER_ID INT,
    LOGIN_TIMESTAMP DATETIME NOT NULL,
    SESSION_ID INT PRIMARY KEY,
    SESSION_SCORE INT,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Users Table
INSERT INTO USERS VALUES (1, 'Alice', 'Active');
INSERT INTO USERS VALUES (2, 'Bob', 'Inactive');
INSERT INTO USERS VALUES (3, 'Charlie', 'Active');
INSERT INTO USERS  VALUES (4, 'David', 'Active');
INSERT INTO USERS  VALUES (5, 'Eve', 'Inactive');
INSERT INTO USERS  VALUES (6, 'Frank', 'Active');
INSERT INTO USERS  VALUES (7, 'Grace', 'Inactive');
INSERT INTO USERS  VALUES (8, 'Heidi', 'Active');
INSERT INTO USERS VALUES (9, 'Ivan', 'Inactive');
INSERT INTO USERS VALUES (10, 'Judy', 'Active');

-- Logins Table 
INSERT INTO LOGINS VALUES (1, '2023-07-15 09:30:00', 1001, 85);
INSERT INTO LOGINS VALUES (2, '2023-07-22 10:00:00', 1002, 90);
INSERT INTO LOGINS VALUES (3, '2023-08-10 11:15:00', 1003, 75);
INSERT INTO LOGINS VALUES (4, '2023-08-20 14:00:00', 1004, 88);
INSERT INTO LOGINS VALUES (5, '2023-09-05 16:45:00', 1005, 82);
INSERT INTO LOGINS  VALUES (6, '2023-10-12 08:30:00', 1006, 77);
INSERT INTO LOGINS  VALUES (7, '2023-11-18 09:00:00', 1007, 81);
INSERT INTO LOGINS VALUES (8, '2023-12-01 10:30:00', 1008, 84);
INSERT INTO LOGINS  VALUES (9, '2023-12-15 13:15:00', 1009, 79);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1011, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2024-01-25 09:30:00', 1012, 90);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-02-05 11:00:00', 1013, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2024-03-01 14:30:00', 1014, 91);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-03-15 16:00:00', 1015, 83);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2024-04-12 08:00:00', 1016, 80);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (7, '2024-05-18 09:15:00', 1017, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (8, '2024-05-28 10:45:00', 1018, 87);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (9, '2024-06-15 13:30:00', 1019, 76);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-25 15:00:00', 1010, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-26 15:45:00', 1020, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-27 15:00:00', 1021, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-28 15:45:00', 1022, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1101, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-01-25 09:30:00', 1102, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-01-15 11:00:00', 1103, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2023-11-10 07:45:00', 1201, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2023-11-25 09:30:00', 1202, 84);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2023-11-15 11:00:00', 1203, 80);
*/

-- SQL Platform Used: Microsoft SQL Server

-- Analytical Questions: 

/* 1. Which users did not log in during the past 5 months? 
return: username. */

SELECT u.USER_NAME
FROM users u
JOIN logins l ON u.USER_ID = l.USER_ID
GROUP BY u.USER_ID
	,u.USER_NAME
HAVING MAX(l.LOGIN_TIMESTAMP) < DATEADD(MONTH, - 5, GETDATE());

/* 2. How many users and sessions were there in each quarter, ordered from newest to oldest?
return: first_day_of_quarter, no_of_users, no_of_sessions */

WITH cte1
AS (
	SELECT USER_ID, SESSION_ID
		,CASE 
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 1
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 1, 1)
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 2
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 4, 1)
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 3
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 7, 1)
			ELSE DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 10, 1)
			END AS first_day_of_quarter
	FROM logins
	)
SELECT first_day_of_quarter, COUNT(DISTINCT USER_ID) AS no_of_users, COUNT(DISTINCT SESSION_ID) AS no_of_sessions
FROM cte1
GROUP BY first_day_of_quarter
ORDER BY first_day_of_quarter DESC;

/* 3. Which users logged in during January 2024 but did not log in during November 2023?
return: user_id */

SELECT DISTINCT USER_ID
FROM logins
WHERE DATEPART(YEAR, LOGIN_TIMESTAMP) = '2024'
	AND DATEPART(MONTH, LOGIN_TIMESTAMP) = '1'

EXCEPT

SELECT DISTINCT USER_ID
FROM logins
WHERE DATEPART(YEAR, LOGIN_TIMESTAMP) = '2023'
	AND DATEPART(MONTH, LOGIN_TIMESTAMP) = '11';

/* 4. What is the percentage change in sessions from the last quarter?
return: first_day_of_quarter, no_of_users, no_of_sessions, sessions_cnt_prev, session_percent_change */

WITH cte1
AS (
	SELECT USER_ID, SESSION_ID
		,CASE 
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 1
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 1, 1)
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 2
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 4, 1)
			WHEN DATEPART(QUARTER, LOGIN_TIMESTAMP) = 3
				THEN DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 7, 1)
			ELSE DATEFROMPARTS(DATEPART(YEAR, LOGIN_TIMESTAMP), 10, 1)
			END AS first_day_of_quarter FROM logins
	)
	,cte2
AS (
	SELECT first_day_of_quarter, COUNT(DISTINCT USER_ID) AS no_of_users, COUNT(DISTINCT SESSION_ID) AS no_of_sessions
	FROM cte1 GROUP BY first_day_of_quarter
	)
SELECT *, LAG(no_of_sessions, 1) OVER (ORDER BY first_day_of_quarter) AS sessions_cnt_prev
	,(no_of_sessions - LAG(no_of_sessions, 1) OVER (ORDER BY first_day_of_quarter)) * 100.0 / 
	LAG(no_of_sessions, 1) OVER (ORDER BY first_day_of_quarter) AS session_percent_change
FROM cte2;

/* 5. Which user had the highest session score each day?
return: login_date, userid, score */

WITH cte1
AS (
	SELECT USER_ID
		,CAST(LOGIN_TIMESTAMP AS DATE) AS login_date
		,SUM(SESSION_SCORE) AS total_score
	FROM logins
	GROUP BY USER_ID
		,CAST(LOGIN_TIMESTAMP AS DATE)
	)
	,cte2
AS (
	SELECT login_date, USER_ID, total_score
		,MAX(total_score) OVER (PARTITION BY login_date) AS highest_session_score
	FROM cte1
	)
SELECT login_date
	,USER_ID
	,highest_session_score
FROM cte2
WHERE total_score = highest_session_score;

/* 6. Which users had a session every single day since their first login?
return: user_id */

WITH cte1
AS (
	SELECT USER_ID
		,COUNT(DISTINCT cast(LOGIN_TIMESTAMP AS DATE)) AS no_of_login_days
		,MIN(cast(LOGIN_TIMESTAMP AS DATE)) AS first_login
		,MAX(cast(LOGIN_TIMESTAMP AS DATE)) AS last_login
	FROM logins
	GROUP BY USER_ID
	)
SELECT *
FROM cte1
WHERE no_of_login_days = DATEDIFF(DAY, first_login, last_login) + 1
	OR DATEDIFF(DAY, first_login, last_login) = 0;

/* 7. On what dates there were no logins at all?
return: login_date */

WITH rec_cte
AS (
	SELECT cast(MIN(LOGIN_TIMESTAMP) AS DATE) AS first_login
		,cast(MAX(LOGIN_TIMESTAMP) AS DATE) AS last_login
	FROM logins
	
	UNION ALL
	
	SELECT DATEADD(DAY, 1, first_login) AS first_login
		,last_login
	FROM rec_cte
	WHERE first_login < last_login
	)
SELECT first_login AS login_dates
FROM rec_cte
WHERE first_login NOT IN (
		SELECT cast(LOGIN_TIMESTAMP AS DATE)
		FROM logins
		)
OPTION (MAXRECURSION 500);
