use h1b_visa;

select * from h1b_data;
select count(*) from h1b_data;

describe h1b_data;

set sql_safe_updates = 0;


update h1b_data set WAGE_RATE_OF_PAY_TO = 
case when WAGE_RATE_OF_PAY_TO = "" or replace(replace(WAGE_RATE_OF_PAY_TO,"$",""),",","")="0"
or replace(replace(WAGE_RATE_OF_PAY_TO,"$",""),",","") = '0.00'
then NULL else
cast(replace(replace(WAGE_RATE_OF_PAY_TO ,"$",""),",","") as decimal(10,2))
end;

update h1b_data set WAGE_RATE_OF_PAY_TO =
case when WAGE_RATE_OF_PAY_FROM = "" then null
else cast(replace(replace(WAGE_RATE_OF_PAY_FROM,"$",""),",","") as decimal(10,2))
end;

select count(*) from information_schema.columns where table_name = 'h1b_data';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'h1b_data';

select case_number, count(case_number) as Count_caseNo from h1b_data
group by case_number having count(case_number)>1;

select count(*), count(case when case_number is null then 1 end) as Null_count from h1b_data;

select * from h1b_data limit 10;

select distinct(JOB_TITLE), count(*) from h1b_data group by job_title;

-- Table creation
create table employer as
select EMPLOYER_NAME, EMPLOYER_ADDRESS1, EMPLOYER_ADDRESS2, EMPLOYER_CITY, EMPLOYER_STATE, EMPLOYER_POSTAL_CODE, EMPLOYER_COUNTRY,
EMPLOYER_PROVINCE, EMPLOYER_PHONE, EMPLOYER_PHONE_EXT, EMPLOYER_POC_LAST_NAME, EMPLOYER_POC_FIRST_NAME, EMPLOYER_POC_MIDDLE_NAME,
EMPLOYER_POC_JOB_TITLE, EMPLOYER_POC_ADDRESS1, EMPLOYER_POC_ADDRESS2, EMPLOYER_POC_CITY, EMPLOYER_POC_STATE, EMPLOYER_POC_POSTAL_CODE,
EMPLOYER_POC_COUNTRY, EMPLOYER_POC_PROVINCE, EMPLOYER_POC_PHONE, EMPLOYER_POC_PHONE_EXT, EMPLOYER_POC_EMAIL
from h1b_data;

create table agent as
select AGENT_REPRESENTING_EMPLOYER, AGENT_ATTORNEY_LAST_NAME, AGENT_ATTORNEY_FIRST_NAME, AGENT_ATTORNEY_MIDDLE_NAME,
AGENT_ATTORNEY_ADDRESS1, AGENT_ATTORNEY_ADDRESS2, AGENT_ATTORNEY_CITY, AGENT_ATTORNEY_STATE, AGENT_ATTORNEY_POSTAL_CODE,
AGENT_ATTORNEY_COUNTRY, AGENT_ATTORNEY_PROVINCE, AGENT_ATTORNEY_PHONE, AGENT_ATTORNEY_PHONE_EXT, AGENT_ATTORNEY_EMAIL_ADDRESS
FROM h1b_data;

Alter table employer add EMPLOYER_NAME varchar(200);

select DISTINCT(JOB_TITLE),count(JOB_TITLE) from h1b_data GROUP BY JOB_TITLE order by count(JOB_TITLE) desc;

with OneQuery as (select DISTINCT(JOB_TITLE),count(JOB_TITLE) as Counts from h1b_data GROUP BY JOB_TITLE order by count(JOB_TITLE) desc)
select ((6081+3919+1984)/sum(counts))*100 as PercentOfSoftwareGuys from OneQuery;

-- Only Software Engineers (not included Database engineers, Query experts, BI, Analysts etc who are known to work in the IT sector)
-- constitute to 1/10th of the entire h1b applications

select max(count(EMPLOYER_NAME)) from employer group by employer_name;

-- Picking the top employer state and industry wise

WITH RankedEmployers AS (
SELECT employer_state, SOC_Title, employer_name, COUNT(*) AS EmployerCount,
RANK() OVER (PARTITION BY employer_state ORDER BY COUNT(*) DESC) AS StateRank,
RANK() OVER (PARTITION BY SOC_Title ORDER BY COUNT(*) DESC) AS IndustryRank
FROM h1b_data GROUP BY employer_state, SOC_title, employer_name)
SELECT employer_state, SOC_Title, employer_name, EmployerCount, StateRank, IndustryRank
FROM RankedEmployers WHERE IndustryRank = 1;

-- Evidently, if an h1b applicant targets to work as an accountant in Rubrik / EY, they have a greater chance at converting

-- Finding the jobs that are paying the most

update h1b_data set WAGE_RATE_OF_PAY_FROM = 
case when WAGE_RATE_OF_PAY_FROM = "" or replace(replace(WAGE_RATE_OF_PAY_TO,"$",""),",","")="0"
or replace(replace(WAGE_RATE_OF_PAY_FROM,"$",""),",","") = '0.00'
then NULL else
cast(replace(replace(WAGE_RATE_OF_PAY_FROM ,"$",""),",","") as decimal(10,2))
end;

select Job_title, employer_name, WAGE_RATE_OF_PAY_FROM, Case_status from h1b_data
where case_status = 'Certified' order by WAGE_RATE_OF_PAY_FROM desc;

-- Real estate Finance Analyst in Banner Property Management LLC,
-- Software developers in RTR group & PNC Financial services group,
-- devops engineer in dataquad Inc
-- are few of the areas which h1b applicants should target to work, because they are offering higher pay and a Certified Case status

-- Agent representing is better at conversion or doing it by oneself?

select count(case_number), AGENT_REPRESENTING_EMPLOYER, case_status from h1b_data group by case_status, AGENT_REPRESENTING_EMPLOYER;

select (80110+4518)/(29659+3499);
-- This implies that there is a 2.5x chance of getting certified h1b visa to those who opt in for the services of an agent.
