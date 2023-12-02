/* SQL Portfolio project - Credit Card Transactions
import the credit_card_transcations.xls file in any sql platform with table name : credit_card_transcations
write 4-6 queries to explore the dataset and solve below questions 

1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
2- write a query to print highest spend month and amount spent in that month for each card type
3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
4- write a query to find city which had lowest percentage spend for gold card type
5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
6- write a query to find percentage contribution of spends by females for each expense type
7- which card and expense type combination saw highest month over month growth in Jan-2014
8- during weekends which city has highest total spend to total no of transcations ratio 
9- which city took least number of days to reach its 500th transaction after the first transaction in that city. */

/* 1- write a query to print top 5 cities with highest spends and their percentage contribution 
of total credit card spends */

with cte1 as
(select city, SUM(amount) as city_spend
from credit_card_transcations
group by city)
, cte2 as
(select SUM(amount) as total_credit_card_spends
from credit_card_transcations)
, cte3 as
(select *,
DENSE_RANK() over(order by c1.city_spend desc) drnk
from cte1 c1, cte2 c2)
select city, city_spend, city_spend / total_credit_card_spends * 100 as percentage_contribution
from cte3
where drnk <= 5;
 
-- 2- write a query to print highest spend month and amount spent in that month for each card type

with cte1 as
(select top 1 DATEPART(YEAR, transaction_date) as trans_year
, DATEPART(MONTH, transaction_date) as trans_month
, SUM(amount) as total_amount
from credit_card_transcations
group by DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
order by total_amount desc)
select card_type, DATEPART(YEAR, transaction_date) as trans_year
, DATEPART(MONTH, transaction_date) as trans_month, SUM(amount) as total_spend
from credit_card_transcations
where DATEPART(YEAR, transaction_date) in (select trans_year from cte1)
and DATEPART(MONTH, transaction_date) in (select trans_month from cte1)
group by card_type, DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date);

/* 3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type) */

with cte1 as
(select *
, SUM(amount) over(partition by card_type order by transaction_date, transaction_id) as cum_amt
from credit_card_transcations)
, cte2 as
(select *
, DENSE_RANK() over(partition by card_type order by cum_amt) as drnk
from cte1
where cum_amt >= 1000000)
select * 
from cte2
where drnk = 1;

--Alternate Solution using LAG Window FUNCTION
with cte1 as
(select *
, SUM(amount) over(partition by card_type order by transaction_date, transaction_id) as cum_amt
from credit_card_transcations)
, cte2 as
(select *
, LAG(cum_amt, 1) over(partition by card_type order by transaction_date, transaction_id) as prev_cum_amt
from cte1)
select * 
from cte2
where cum_amt >= 1000000 and prev_cum_amt < 1000000;

-- 4- write a query to find city which had lowest percentage spend for gold card type

with cte1 as
(select city
, SUM(amount) as total_amt
, SUM(case when card_type = 'Gold' then amount end) as gold_card_amt
from credit_card_transcations
group by city)
select top 1 city, gold_card_amt / total_amt * 100 as per_spend
from cte1
where gold_card_amt > 0
order by per_spend;

-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte1 as
(select city, exp_type, SUM(amount) as total_amt 
from credit_card_transcations
group by city, exp_type)
, cte2 as
(select *
, DENSE_RANK() over(partition by city order by total_amt) as drnk_lowest
, DENSE_RANK() over(partition by city order by total_amt desc) as drnk_highest
from cte1)
select city
, MAX(case when drnk_highest = 1 then exp_type end) as highest_expense_type
, MAX(case when drnk_lowest = 1 then exp_type end) as lowest_expense_type
from cte2
group by city;

-- 6- write a query to find percentage contribution of spends by females for each expense type

select exp_type
, SUM(amount) as total_exp_type_amt
, SUM(case when gender = 'F' then amount end) as female_contribution
, SUM(case when gender = 'F' then amount end) / SUM(amount) * 100 as per_contribution
from credit_card_transcations
group by exp_type
order by per_contribution;

-- 7- which card and expense type combination saw highest month over month growth in Jan-2014

with cte1 as
(select DATEPART(YEAR, transaction_date) as trans_year
, DATEPART(MONTH, transaction_date) as trans_month
, card_type, exp_type, SUM(amount) as total_amt
from credit_card_transcations
group by DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date), card_type, exp_type)
, cte2 as
(select * 
, LAG(total_amt, 1) over(partition by card_type, exp_type order by trans_year, trans_month) as prev_trans_amt
from cte1)
select top 1 *, (total_amt - prev_trans_amt) / prev_trans_amt * 100 as mom_growth 
from cte2
where trans_year = '2014' and trans_month = '1'
order by mom_growth desc;

-- 8- during weekends which city has highest total spend to total no of transcations ratio

select top 1 city, SUM(amount) / COUNT(1) as ratio
from credit_card_transcations
where DATEPART(WEEKDAY, transaction_date) in ('1', '7')
group by city
order by ratio desc;

-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte1 as
(select city
from credit_card_transcations
group by city
having COUNT(1) >= 500)
, cte2 as
(select * 
, ROW_NUMBER() over(partition by city order by transaction_date, transaction_id) as rn
from credit_card_transcations
where city in (select city from cte1))
, cte3 as
(select city, MIN(transaction_date) as first_trans_date, MAX(transaction_date) as five_hundredth_trans_date
from cte2
where rn <= 500
group by city)
select top 1 *, DATEDIFF(DAY, first_trans_date, five_hundredth_trans_date) as diff_no_of_days 
from cte3
order by diff_no_of_days;
