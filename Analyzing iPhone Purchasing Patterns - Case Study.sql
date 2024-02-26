-- SQL Case Study - Analyzing iPhone Purchasing Patterns

-- Script to create and insert data:

CREATE TABLE iphone_dataset 
(
    user_id	VARCHAR(20),
    iphone_model VARCHAR(20)
);
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('1', 'i-11');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('1', 'i-12');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('1', 'i-13');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('1', 'i-14');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('1', 'i-15');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('2', 'i-15');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('3', 'i-12');
INSERT INTO iphone_dataset (user_id, iphone_model) VALUES ('3', 'i-15');

CREATE TABLE iphone_products_dim 
(
    iphone_model VARCHAR(20)
);
INSERT INTO iphone_products_dim (iphone_model) VALUES ('i-11');
INSERT INTO iphone_products_dim (iphone_model) VALUES ('i-12');
INSERT INTO iphone_products_dim (iphone_model) VALUES ('i-13');
INSERT INTO iphone_products_dim (iphone_model) VALUES ('i-14');
INSERT INTO iphone_products_dim (iphone_model) VALUES ('i-15');

----------------------------------------------------------------------------------

-- SQL Platform Used: Microsoft SQL Server

/*Q1. Write an SQL query to find the users who exclusively purchased iPhone 15 only and 
did not buy any other iPhone model. */

WITH cte1
AS (
	SELECT user_id
		,COUNT(DISTINCT iphone_model) AS no_of_models_purchased
	FROM iphone_dataset
	GROUP BY user_id
	)
SELECT DISTINCT user_id
FROM iphone_dataset
WHERE user_id IN (
		SELECT user_id
		FROM cte1
		WHERE no_of_models_purchased = 1
		)
	AND iphone_model = 'i-15';

/*Q2. Write an SQL query to identify users who have upgraded their iPhone model from iPhone 12 to iPhone 15, 
and they have only purchased two iPhone models in total. */

WITH cte1
AS (
	SELECT user_id
		,iphone_model AS current_iphone_model
		,LEAD(iphone_model, 1) OVER (PARTITION BY user_id ORDER BY iphone_model) AS next_purchased_model
		,COUNT(1) OVER (PARTITION BY user_id) AS no_of_models
	FROM iphone_dataset
	)
SELECT user_id
FROM cte1
WHERE current_iphone_model = 'i-12'
	AND next_purchased_model = 'i-15'
	AND no_of_models = 2;

/*Q3. Consider you are having iphone_products_dim table which contains all the available iphone models. 
Write an SQL query to retrieve the users who have purchased every iPhone model listed in the 
iphone_products_dim table. */

WITH cte1
AS (
	SELECT user_id, iphone_model
	FROM iphone_dataset
	GROUP BY user_id, iphone_model
	)
	,cte2
AS (
	SELECT c1.user_id, COUNT(1) OVER (PARTITION BY c1.user_id) AS no_of_models
	FROM cte1 c1
	JOIN iphone_products_dim ipd ON c1.iphone_model = ipd.iphone_model
	)
SELECT DISTINCT user_id
FROM cte2
WHERE no_of_models IN (
		SELECT COUNT(1) AS total_iphone_models FROM iphone_products_dim
		);