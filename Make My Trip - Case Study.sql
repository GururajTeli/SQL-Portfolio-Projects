-- SQL Case Study - Make My Trip

-- Script to create and insert data:

CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');
;
CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);
INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');
----------------------------------------------------------------------------------

-- SQL Platform Used: Microsoft SQL Server

/* 1. Write a SQL query that gives below output.(Summary at segment level)
Segment Total_user_count User_who_booked_flight_in_apr2022
s1	3	2
s2	2	2
s3	5	1 */

SELECT u.Segment
	,COUNT(DISTINCT u.User_id) AS Total_user_count
	,COUNT(DISTINCT CASE 
			WHEN DATEPART(YEAR, b.Booking_date) = 2022
				AND DATEPART(MONTH, b.Booking_date) = 4
				AND b.Line_of_business = 'Flight'
				THEN b.User_id
			END) AS User_who_booked_flight_in_apr2022
FROM user_table u
LEFT JOIN booking_table b ON u.User_id = b.User_id
GROUP BY u.Segment;

-- 2. Write a query to identify users whose first booking was a hotel booking.

WITH cte1
AS (
	SELECT User_id
		,Booking_date
		,Line_of_business
		,DENSE_RANK() OVER (
			PARTITION BY User_id ORDER BY booking_date
			) AS drnk
	FROM booking_table
	)
SELECT User_id
FROM cte1
WHERE drnk = 1
	AND Line_of_business = 'Hotel';

--Alternate Solution using first_value() function:

WITH cte1
AS (
	SELECT User_id
		,Booking_date
		,Line_of_business
		,first_value(Line_of_business) OVER (
			PARTITION BY User_id ORDER BY booking_date
			) AS first_booking
	FROM booking_table
	)
SELECT DISTINCT User_id
FROM cte1
WHERE first_booking = 'Hotel';

-- 3. Write a query to calculate the days between first and last booking of each user.

WITH cte1
AS (
	SELECT User_id
		,MIN(Booking_date) AS first_booking_date
		,MAX(Booking_date) AS last_booking_date
	FROM booking_table
	GROUP BY User_id
	)
SELECT User_id
	,first_booking_date
	,last_booking_date
	,DATEDIFF(DAY, first_booking_date, last_booking_date) AS diff_in_days
FROM cte1;

-- 4. Write a query to count the number of flights and hotel bookings in each of the user segments for the year 2022.

SELECT u.Segment
	,COUNT(CASE 
			WHEN b.Line_of_business = 'Flight'
				THEN b.User_id
			END) AS no_of_flights_bookings
	,COUNT(CASE 
			WHEN b.Line_of_business = 'Hotel'
				THEN b.User_id
			END) AS no_of_hotel_bookings
FROM booking_table b
INNER JOIN user_table u ON b.User_id = u.User_id
WHERE DATEPART(YEAR, b.Booking_date) = 2022
GROUP BY u.Segment;
