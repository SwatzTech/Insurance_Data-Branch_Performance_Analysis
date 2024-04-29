create database insurance_analytics;
use insurance_analytics;

create table if not exists fees(client varchar(5) not null, 
branch_name varchar(20) not null,
solution_group varchar(100) not null,
acct_exec varchar(30) not null,
income_class enum('Cross Sell','New','Renewal','') not null,
amount float,
income_due_date varchar(10),
rev_trans_type varchar(10));

desc fees;
select * from fees;

#SELECT @@secure_file_priv; 
#SHOW VARIABLES LIKE "secure_file_priv";
#set global local_infile=1;
#set secure_file_priv=0;
#show variables like "local_infile";

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fees.csv' 
INTO TABLE fees 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SET income_due_date = STR_TO_DATE(@income_due_date, '%d-%m-%Y');

select * from fees;

-- --------------------------------------------------------------------------------------

create table meetings(acct_exec varchar(30) not null,
branch_name varchar(20) not null,
attendees varchar(30),
meeting_date varchar(11) not null);

desc meetings;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/meeting.csv'
into table meetings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from meetings;
-- --------------------------------------------------------------------------------------
create table budgets(
branch varchar(20) not null,
emp_name varchar(30) not null,
new_role varchar(20),
new_budget float default 0.0,
cross_sell_budget float default 0.0,
renewal_budget float default 0.0);

desc budgets;

/*
	NOTE : If the last column in any row contains empty/NULL values, 
    data import fails with the error code 1265
    Hence renewal budget value in Row 2 and 6 in datafile had to be replaced with 0
*/
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Individual Budgets.csv'
into table budgets
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(branch, emp_name, new_role, @var1, @var2, @var3)
/*SET new_budget = IF(@var1='', NULL, @var1),
cross_sell_budget = IF(@var2='', NULL, @var2),
renewal_budget = nullif(@var3, '');*/
SET new_budget = NULLIF(@var1,''),
cross_sell_budget = NULLIF(@var2,''),
renewal_budget = NULLIF(@var3, '');

select * from budgets;

-- --------------------------------------------------------------------------------------

create table opportunity(
oppty_name varchar(30) not null,
oppty_id char(13) not null,
acct_exec varchar(30) not null,
prem_amount int default 0 not null,
rev_amount int default 0 not null,
closing_date varchar(10) not null,
stage enum('Qualify Opportunity','Negotiate','Propose Solution') not null,
branch varchar(20) not null,
specialty varchar(50),
product_group varchar(40),
product_sub_group varchar(40),
risk_details varchar(60));


load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Opportunity.csv'
into table opportunity
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- --------------------------------------------------------------------------------------

create table invoice(
invoice_number int not null,
invoice_date varchar(10) not null,
rev_transaction_type enum('Fees','Brokerage'),
branch varchar(20) not null,
solution_group varchar(50),
acct_exec varchar(30) not null,
income_class enum('Cross Sell','Renewal','New',''),
client_name varchar(10),
policy_number varchar(40),
amount int not null,
income_due_date varchar(11));

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoices.csv'
into table invoice
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- --------------------------------------------------------------------------------------

create table brokerage(
client_name varchar(10),
policy_number varchar(60),
policy_status enum('Active','Inactive'),
policy_start_date varchar(10) not null,
policy_end_date varchar(10) not null,
product_group varchar(50),
acct_exec varchar(30) not null,
branch varchar(20) not null,
solution_group varchar(50),
income_class enum('Cross Sell','Renewal','New',''),
amount float not null,
income_due_date varchar(10),
rev_transaction_type enum('Fees','Brokerage'),
renewal_status enum('Renewal','Inception','Endorsement','Lapse'),
lapse_reason varchar(255),
last_updated_date varchar(11));

#alter table brokerage change column income_class income_class varchar(10);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brokerage.csv'
into table brokerage
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from brokerage;