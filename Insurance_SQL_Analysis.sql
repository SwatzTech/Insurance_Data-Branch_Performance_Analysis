/*
	KPI 1 - No of Invoice by Accnt Exec
*/
select acct_exec as 'Account Executive', income_class, count(invoice_number) as num_of_invoice
from invoice
group by acct_exec, income_class
order by acct_exec;

/*
	KPI 2 - Yearly meeting count
*/

select year(str_to_date(meeting_date, '%d-%m-%Y')) as year, count(meeting_date) as num_of_meetings
from meetings
group by year;

/*
	KPI 3 - Target, Placed, Invoiced for all income classes
*/
with placed_achieved as (
select ic as income_class, sum(amt) as placed_amount from (
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from brokerage group by income_class)
union
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from fees group by income_class)) t
group by income_class
),
invoiced as (
select income_class, sum(amount) as invoiced_amount from invoice
group by income_class
),
target as (
select 'New' as income_class, sum(new_budget) as target from budgets
union
select 'Renewal' as income_class, sum(renewal_budget) as target from budgets
union
select 'Cross Sell' as income_class, sum(cross_sell_budget) as target from budgets
)
select * from placed_achieved join invoiced using(income_class)
join target using(income_class);	

/*
	KPI 4 - Stage funnel by Revenue
*/
select stage, sum(rev_amount) as revenue
from opportunity
group by stage
order by revenue desc;

/*
	KPI 5 - No of Meetings by Accnt Exec
*/
select acct_exec as 'Account Executive', count(meeting_date) as num_of_meetings
from meetings
group by acct_exec
order by num_of_meetings;

/*
	KPI 6 - Opportunity by Revenue
*/
select oppty_name as Opportunity, sum(rev_amount) as revenue
from opportunity
group by Opportunity
order by revenue desc;

# Top open opportunity
select oppty_name as Opportunity, sum(rev_amount) as revenue
from opportunity
where stage in('Qualify Opportunity','Propose Solution')
group by Opportunity
order by revenue desc;

# Total Opportunities
select count(oppty_name) as 'Total Opportunities'
from opportunity;

# Total Open Opportunities
select count(oppty_name) as 'Total Opportunities'
from opportunity
where stage in('Qualify Opportunity','Propose Solution');

# Cross Sell placed achievement
with placed_achieved as (
select ic as income_class, sum(amt) as placed_amount from (
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from brokerage group by income_class)
union
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from fees group by income_class)) t
group by income_class
having income_class='Cross Sell'
),
total as (select sum(cross_sell_budget) as total_amount 
from budgets)
select concat(round((placed_amount/total_amount)*100, 2),'%') as 'Cross Sell Placed Achievement %'
from placed_achieved, total;

# Cross Sell invoiced achievement
with invoiced as (
select income_class, sum(amount) as invoiced_amount 
from invoice
group by income_class
having income_class='Cross Sell'),
total as (select sum(cross_sell_budget) as total_amount 
from budgets)
select concat(round((invoiced_amount/total_amount)*100, 2),'%') as 'Cross Sell Invoiced Achievement %'
from invoiced, total;

# New placed achievement
with placed_achieved as (
select ic as income_class, sum(amt) as placed_amount from (
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from brokerage group by income_class)
union
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from fees group by income_class)) t
group by income_class
having income_class='New'
),
total as (select sum(new_budget) as total_amount 
from budgets)
select concat(round((placed_amount/total_amount)*100, 2),'%') as 'New Placed Achievement %'
from placed_achieved, total;

# New invoiced achievement
with invoiced as (
select income_class, sum(amount) as invoiced_amount 
from invoice
group by income_class
having income_class='New'),
total as (select sum(new_budget) as total_amount 
from budgets)
select concat(round((invoiced_amount/total_amount)*100, 2),'%') as 'Invoiced Achievement %'
from invoiced, total;

# Renewal placed achievement
with placed_achieved as (
select ic as income_class, sum(amt) as placed_amount from (
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from brokerage group by income_class)
union
(select income_class COLLATE utf8mb4_general_ci as ic, sum(amount) as amt from fees group by income_class)) t
group by income_class
having income_class='Renewal'
),
total as (select sum(renewal_budget) as total_amount 
from budgets)
select concat(round((placed_amount/total_amount)*100, 2),'%') as 'Renewal Placed Achievement %'
from placed_achieved, total;

# Renewal invoiced achievement
with invoiced as (
select income_class, sum(amount) as invoiced_amount 
from invoice
group by income_class
having income_class='Renewal'),
total as (select sum(renewal_budget) as total_amount 
from budgets)
select concat(round((invoiced_amount/total_amount)*100, 2),'%') as 'Invoiced Achievement %'
from invoiced, total;

# Opportunity-Product Distribution
select product_group, count(oppty_name) as num_opportunities
from opportunity
group by product_group
order by num_opportunities desc;