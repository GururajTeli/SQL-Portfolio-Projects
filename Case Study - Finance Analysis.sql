/* SQL Challenge - Finance Analysis

About the Challenge -
This challenge is associated with Finance Analysis as a Finance Analyst for 'The Big Bank' and the task is finding out about 
the customers and their banking behavior. You also have to examine the accounts they hold and the type of transactions 
they make to develop greater insight into your customers. */

-- Script to create and insert data:

-- Create the Customers table
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(2) NOT NULL
);

-- Populate the Customers table
INSERT INTO Customers (CustomerID, FirstName, LastName, City, State)
VALUES (1, 'John', 'Doe', 'New York', 'NY'),
(2, 'Jane', 'Doe', 'New York', 'NY'),
(3, 'Bob', 'Smith', 'San Francisco', 'CA'),
(4, 'Alice', 'Johnson', 'San Francisco', 'CA'),
(5, 'Michael', 'Lee', 'Los Angeles', 'CA'),
(6, 'Jennifer', 'Wang', 'Los Angeles', 'CA');

-- Create the Branches table
CREATE TABLE Branches (
BranchID INT PRIMARY KEY,
BranchName VARCHAR(50) NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(2) NOT NULL
);

-- Populate the Branches table
INSERT INTO Branches (BranchID, BranchName, City, State)
VALUES (1, 'Main', 'New York', 'NY'),
(2, 'Downtown', 'San Francisco', 'CA'),
(3, 'West LA', 'Los Angeles', 'CA'),
(4, 'East LA', 'Los Angeles', 'CA'),
(5, 'Uptown', 'New York', 'NY'),
(6, 'Financial District', 'San Francisco', 'CA'),
(7, 'Midtown', 'New York', 'NY'),
(8, 'South Bay', 'San Francisco', 'CA'),
(9, 'Downtown', 'Los Angeles', 'CA'),
(10, 'Chinatown', 'New York', 'NY'),
(11, 'Marina', 'San Francisco', 'CA'),
(12, 'Beverly Hills', 'Los Angeles', 'CA'),
(13, 'Brooklyn', 'New York', 'NY'),
(14, 'North Beach', 'San Francisco', 'CA'),
(15, 'Pasadena', 'Los Angeles', 'CA');

-- Create the Accounts table
CREATE TABLE Accounts (
AccountID INT PRIMARY KEY,
CustomerID INT NOT NULL,
BranchID INT NOT NULL,
AccountType VARCHAR(50) NOT NULL,
Balance DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

-- Populate the Accounts table
INSERT INTO Accounts (AccountID, CustomerID, BranchID, AccountType, Balance)
VALUES (1, 1, 5, 'Checking', 1000.00),
(2, 1, 5, 'Savings', 5000.00),
(3, 2, 1, 'Checking', 2500.00),
(4, 2, 1, 'Savings', 10000.00),
(5, 3, 2, 'Checking', 7500.00),
(6, 3, 2, 'Savings', 15000.00),
(7, 4, 8, 'Checking', 5000.00),
(8, 4, 8, 'Savings', 20000.00),
(9, 5, 14, 'Checking', 10000.00),
(10, 5, 14, 'Savings', 50000.00),
(11, 6, 2, 'Checking', 5000.00),
(12, 6, 2, 'Savings', 10000.00),
(13, 1, 5, 'Credit Card', -500.00),
(14, 2, 1, 'Credit Card', -1000.00),
(15, 3, 2, 'Credit Card', -2000.00);

-- Create the Transactions table
CREATE TABLE Transactions (
TransactionID INT PRIMARY KEY,
AccountID INT NOT NULL,
TransactionDate DATE NOT NULL,
Amount DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

-- Populate the Transactions table
INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount)
VALUES (1, 1, '2022-01-01', -500.00),
(2, 1, '2022-01-02', -250.00),
(3, 2, '2022-01-03', 1000.00),
(4, 3, '2022-01-04', -1000.00),
(5, 3, '2022-01-05', 500.00),
(6, 4, '2022-01-06', 1000.00),
(7, 4, '2022-01-07', -500.00),
(8, 5, '2022-01-08', -2500.00),
(9, 6, '2022-01-09', 500.00),
(10, 6, '2022-01-10', -1000.00),
(11, 7, '2022-01-11', -500.00),
(12, 7, '2022-01-12', -250.00),
(13, 8, '2022-01-13', 1000.00),
(14, 8, '2022-01-14', -1000.00),
(15, 9, '2022-01-15', 500.00);

-----------------------------------------------------

-- SQL Platform Used: Microsoft SQL Server

-- 1. What are the names of all the customers who live in New York?

select FirstName, LastName 
from Customers
where City = 'New York'
group by FirstName, LastName;

-- 2. What is the total number of accounts in the Accounts table?

select count(distinct AccountID) as total_no_of_accounts 
from Accounts;

-- 3. What is the total balance of all checking accounts?

select sum(Balance) as total_balance 
from Accounts
where AccountType = 'Checking';

-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?

select sum(Balance) as total_balance
from Accounts a
inner join Customers c on a.CustomerID = c.CustomerID
where City = 'Los Angeles';

-- 5. Which branch has the highest average account balance?

with cte1 as
(select b.BranchName, avg(a.Balance) as avg_account_balance 
from Branches b
inner join Accounts a on b.BranchID = a.BranchID
group by b.BranchName)
, cte2 as
(select * 
, DENSE_RANK() over(order by avg_account_balance desc) drnk
from cte1)
select BranchName, avg_account_balance 
from cte2 
where drnk = 1;

-- 6. Which customer has the highest current balance in their accounts?

with cte1 as
(select c.CustomerID, c.FirstName, c.LastName, sum(a.Balance) as current_balance 
from Customers c
inner join Accounts a on c.CustomerID = a.CustomerID
group by c.CustomerID, c.FirstName, c.LastName)
, cte2 as
(select *
, DENSE_RANK() over(order by current_balance desc) drnk
from cte1)
select CustomerID, FirstName, LastName, current_balance 
from cte2
where drnk = 1;

-- 7. Which customer has made the most transactions in the Transactions table?

with cte1 as
(select c.CustomerID, c.FirstName, c.LastName, count(t.TransactionID) as no_of_transactions 
from Customers c
inner join Accounts a on c.CustomerID = a.AccountID
inner join Transactions t on a.AccountID = t.AccountID
group by c.CustomerID, c.FirstName, c.LastName)
, cte2 as
(select * 
, DENSE_RANK() over(order by no_of_transactions desc) drnk
from cte1)
select CustomerID, FirstName, LastName, no_of_transactions
from cte2
where drnk = 1;

-- 8.Which branch has the highest total balance across all of its accounts?

with cte1 as
(select b.BranchName, sum(a.Balance) as total_balance 
from Branches b
inner join Accounts a on b.BranchID = a.BranchID
group by b.BranchName)
, cte2 as
(select * 
, DENSE_RANK() over(order by total_balance desc) drnk
from cte1)
select BranchName, total_balance
from cte2
where drnk = 1;

-- 9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?

select top 1 c.CustomerID, c.FirstName, c.LastName, sum(a.Balance) as total_balance
from Customers c
inner join Accounts a on c.CustomerID = a.CustomerID
where a.AccountType in ('Checking', 'Savings')
group by c.CustomerID, c.FirstName, c.LastName
order by total_balance desc;

-- 10. Which branch has the highest number of transactions in the Transactions table?

with cte1 as
(select b.BranchName, count(distinct t.TransactionID) as no_of_transactions 
from Branches b
inner join Accounts a on b.BranchID = a.BranchID
inner join Transactions t on a.AccountID = t.AccountID
group by b.BranchName)
, cte2 as
(select * 
, DENSE_RANK() over(order by no_of_transactions desc) drnk
from cte1)
select BranchName, no_of_transactions
from cte2
where drnk = 1;
