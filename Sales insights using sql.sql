select @@sql_mode;
set session sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- <-------------------------------------- Sales insights of HappyMart(dummy company)------------------------------------>

-- Note :- We will perform all the necessary transformation here before making our dashboard in Power BI, we will be using
-- sql for generating insights from our sales database

-- <--------------------------------------------- Basic Insights -------------------------------------------------------->

-- Let's see all the table present in our database :- 
select *
from customers;

-- Let's see total number of customer of our client?
select count(*) as number_of_customer
from customers;
-- There are total of 38 customer at present

-- Let's see the duration for upto which we have our data?
select *
from date;

select count(*) as duration
from date;
-- We have data of around 3 years this will be basis of our analysis

-- Let see min and max date of which data is present?
select min(date) as first_date, max(date) as last_date
from date;
-- First date is 1/06/2017 and last date is 30/06/2020

-- Let's see market in which our client do business?
select *
from markets;

select count(*) as number_of_markets
from markets;
-- Our client is present in total of 17 markets

select distinct markets_name
from markets;
-- Our client has major market is in india 

-- Let's see the products details
select *
from products;

-- Let's see the transactions details
select *
from transactions;
-- quick insights :-
-- some rows has sales amount as -1 and 0 this need to be taken care of
select distinct market_code
from transactions;

select distinct currency
from transactions; 

-- INR and USD are coming two times may be it is due to white spaces
-- This needs triming and we will do that in power query before making our dashboard. 

-- <------------------------------------------------ Intermidiate insights --------------------------------------------->
delete from transactions
where sales_amount<=0;

select *
from transactions;

select *
from transactions 
where currency = 'USD';

select *
from transactions
where currency = 'USD\r';
delete from transactions
where currency = 'USD\r';
select distinct currency
from transactions;

select *
from transactions
where currency = 'INR'; -- 275 record contains correct name

select *
from transactions
where currency = 'INR\r'; -- Most of the record contains this value so we need to update this value

update transactions
set currency = 'INR'
where currency = 'INR\r';

select distinct currency 
from transactions; -- No we remove all the redundant rows. 

-- In the sales amount column some values are in USD so we need to convert it into INR
select *
from transactions
where currency = 'USD';

update transactions
set sales_amount = sales_amount*80
where currency = 'USD';

select *
from transactions
where currency = 'USD'; -- We corrected our record. 

-- Let's find out top 10 customer of our client
select c.custmer_name, sum(t.sales_amount) as revenue
from customers c
join transactions t on t.customer_code = c.customer_code
group by c.custmer_name
order by revenue desc
limit 10;  -- These are our top 10 customer based on the revenue

select sum(sales_amount) as Revenue
from transactions; -- Total revenue of our client till now is 986 million

select sum(sales_qty) as quantity_sold
from transactions; -- Total quantity of product sold till now is 2.43 million

-- Let's find top 10 market of our client based on the revenue
select m.markets_name, sum(t.sales_amount) as revenue
from markets m
join transactions t on m.markets_code = t.market_code
group by m.markets_name
order by revenue desc
limit 10; -- Delhi/NCR is the top market for our client followed by Mumbai and Ahmedabad

-- Let's figure out which year does our client do their best business :-
select year(d.date) as year, sum(sales_amount) as revenue
from date d 
join transactions t on t.order_date = d.date
group by year 
order by revenue desc; -- The highest revenue was in the year 2018 and lowest is in 2017 which is evident because we have only 
-- 2 quater data is available for 2017. 

-- Let's do some zonal analysis
select zone, sum(sales_amount) as revenue
from markets
join transactions on transactions.market_code = markets.markets_code
group by zone
order by revenue desc;

-- North region generated the most revenue for our client

-- Let's rank the market based on the revenue they generated for our client :-
with temp as (
			select markets_name,zone,sum(sales_amount) as revenue
            from markets
            join transactions on transactions.market_code = markets.markets_code
            group by markets_name)
            
select *, dense_rank() over(order by revenue desc) as overall_ranking
from temp;

-- Ranking of markets based on revenue according to zones :-

with temp2 as (
			select markets_name,zone,sum(sales_amount) as revenue
            from markets
            join transactions on transactions.market_code = markets.markets_code
            group by markets_name)
            
select *, dense_rank() over(partition by zone order by revenue desc) as Zonal_ranking
from temp2;




