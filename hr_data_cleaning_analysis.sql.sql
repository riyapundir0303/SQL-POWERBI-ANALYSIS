-- ==========================================
-- Project: Power BI HR Analytics
-- File: hr_data_cleaning_analysis.sql
-- Description:
--   SQL queries for data cleaning and analysis
--   used in Power BI dashboard
-- Database: MySQL
-- ==========================================
-- CREATE DATABASE PROJECTS;
use projects ;
select birthdate from hr;
set sql_safe_updates = 0;

describe hr;
ALTER table hr 
modify column birthdate DATE ;

UPDATE hr
SET birthdate =
CASE
    -- m/d/yyyy  →  6/29/1984
    WHEN birthdate LIKE '%/%' THEN
        DATE_FORMAT(
            STR_TO_DATE(birthdate, '%m/%d/%Y'),
            '%Y-%m-%d'
        )

    -- dd-mm-yy  →  06-04-91
    WHEN birthdate LIKE '%-%' THEN
        DATE_FORMAT(
            STR_TO_DATE(birthdate, '%d-%m-%y'),
            '%Y-%m-%d'
        )

    ELSE birthdate
END;
select birthdate from hr;


describe hr;
alter table hr
modify column hire_date DATE;

UPDATE hr
set hire_date = case 
   when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%y'),'%Y-%m-%d')
   when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%y'),'%Y-%m-%d')
   else hire_date
end;

UPDATE hr
SET termdate = NULL
WHERE termdate = '';
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate LIKE '%UTC%';
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

alter table hr add column age int;
update hr
set age = timestampdiff(year, birthdate , curdate());

select min(age) as youngest,
max(age) as eldest 
from hr ;
select count(*) 
 from hr
where age<18;

-- QUESTIONS 

-- 1. WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPANY?

select gender,
count(*) as count
from hr 
where age>=18 and termdate is NULL
group by gender; 

-- 2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY?
SELECT RACE , COUNT(*) AS COUNT
 FROM hr
 where age>=18 and termdate is NULL
 group by race 
 order by count(*) desc;

-- 3. WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY?
 select min(age) as youngest ,
 max(age) as eldest 
 from hr 
 where age>=18 and termdate is NULL;

select case
when age>= 18 and age <=24 then '18-24'
when age >=25 and age <= 34 then '25-34'
when age >=35 and age <= 44 then '35-44'
when age >=45 and age <= 54 then '45-54'
when age >=55 and age <= 64 then '55-64'
else '65+'
end as age_group,
count(*) as count 
from hr 
where age>=18 and termdate is NULL
group by age_group 
order by age_group ;

select case
when age>= 18 and age <=24 then '18-24'
when age >=25 and age <= 34 then '25-34'
when age >=35 and age <= 44 then '35-44'
when age >=45 and age <= 54 then '45-54'
when age >=55 and age <= 64 then '55-64'
else '65+'
end as age_group,gender,
count(*) as count 
from hr 
where age>=18 and termdate is NULL
group by age_group,gender 
order by age_group ;

-- 4. HOW MANY EMPLOYEES WORK AT HEADQUARTERS VERSUS REMOTE LOCATION?
select location,
count(*) as count 
from hr 
where age>=18 and termdate is NULL
group by location;

-- 5. WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT WHO HAVE BEEN TERMINATED ?
select round(avg(datediff(termdate, hire_date))/365,0) as avg_length_emp
from hr
where termdate <= curdate()and termdate is not NULL AND age>=18;

-- 6. HOW DOES THE GENDER DISTRIBUTION VARY ACROSS DEPARTMENTS AND JOB TITLES?
select gender,
department,
count(*) as count 
from hr 
where age>=18 and termdate is NULL
group by department , gender 
order by department;

-- 7. WHAT IS THE DISTRIBUTION OF JOB TITLES ACROSS THE COMPANY?
select jobtitle ,count(*) 
from hr 
where age>=18 and termdate is NULL
group by jobtitle
order by jobtitle desc;

-- 8. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?
select department , 
total_count,
terminated_count,
terminated_count/total_count as termination_rate
from (select department , count(*) as total_count,
sum(case when termdate is not null and termdate <= curdate()
then 1 else 0 end ) as terminated_count
from hr 
where age>=18
group by department 
) as subquery 
order by termination_rate desc;

-- 9. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATION BY CITY AND STATE?
select location_state , count(*) as count
from hr 
where age>=18 and termdate is NULL
group by location_state 
order by count(*)desc;

-- 10 HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATE?
select year,
hires,
terminations,
hires-terminations as net_change,
round((hires-terminations/hires)*100,2) as net_change_percent
from (select year(hire_date) as year,
count(*) as hires ,
sum(case when termdate is not null and termdate<=curdate() then 1 else 0 end) as terminations
from hr 
where age>=18 
group by year(hire_date)
) as subquery
order by year asc;


-- 11.WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?
select department ,round(avg(datediff(termdate , hire_date)/365),0) as avg_tenure 
from hr 
where termdate <=curdate() and termdate is not null and age>= 18
group by department;


