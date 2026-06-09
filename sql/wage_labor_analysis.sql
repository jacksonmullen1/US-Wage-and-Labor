— Step 1: Raw Data Staging Table

CREATE TABLE stg_wages(
area VARCHAR(255),
area_title VARCHAR(255),
area_type VARCHAR(255),
prim_state VARCHAR(255),
naics VARCHAR(255),
naics_title VARCHAR(255),
i_group VARCHAR(255),
own_code VARCHAR(255),
occ_code VARCHAR(255),
occ_title VARCHAR(255),
o_group VARCHAR(255),
tot_emp VARCHAR(255),
emp_prse VARCHAR(255),
jobs_1000 VARCHAR(255),
loc_quotient VARCHAR(255),
pct_total VARCHAR(255),
pct_rpt VARCHAR(255),
h_mean VARCHAR(255),
a_mean VARCHAR(255),
mean_prse VARCHAR(255),
h_pct10 VARCHAR(255),
h_pct25 VARCHAR(255),
h_median VARCHAR(255),
h_pct75 VARCHAR(255),
h_pct90 VARCHAR(255),
a_pct10 VARCHAR(255),
a_pct25 VARCHAR(255) ,
a_median VARCHAR(255),
a_pct75 VARCHAR(255) ,
a_pct90 VARCHAR(255),
annual VARCHAR(255),
hourly VARCHAR(255)
);

-- Exploratory Checks

Select * FROM stg_wages
LIMIT 20;


SELECT COUNT(*) FROM stg_wages;

SELECT DISTINCT occ_title FROM stg_wages;


-- Step 2: Data Cleaning and type conversion
-- Remove non-numeric characters
-- Convert cleaned values into numeric data types for analysis

CREATE TABLE analytics_wages AS 
SELECT 
naics_title, 
occ_title,
prim_state AS state, 
NULLIF(REGEXP_REPLACE(tot_emp, '[^0-9.]', '', 'g'), '')::INTEGER AS amount_employed, 
NULLIF(REGEXP_REPLACE(a_mean, '[^0-9.]', '', 'g'), '')::NUMERIC(10,2) AS annual_mean_wage, 
NULLIF(REGEXP_REPLACE(h_mean, '[^0-9.]', '', 'g'), '')::NUMERIC(10,2) AS hourly_mean_wage 
FROM stg_wages;


-- Removing null values from various fields

DELETE FROM analytics_wages
WHERE amount_employed IS NULL;

DELETE FROM analytics_wages
WHERE annual_mean_wage IS NULL;

DELETE FROM analytics_wages
WHERE hourly_mean_wage IS NULL;

-- Validate cleaned dataset

SELECT
    COUNT(*) AS total_rows,
    COUNT(amount_employed) AS employment_rows,
    COUNT(annual_mean_wage) AS wage_rows
FROM analytics_wages;

SELECT * FROM analytics_wages
WHERE amount_employed IS NULL;

SELECT * FROM analytics_wages
WHERE annual_mean_wage IS NULL;


SELECT * FROM analytics_wages
WHERE hourly_mean_wage IS NULL;

-- Step 3: Analytical Queries

-- Top 20 Occupations by Wage

SELECT 
	occ_title AS occupation, 
	hourly_mean_wage,
	annual_mean_wage
FROM analytics_wages
ORDER BY annual_mean_wage DESC NULLS LAST
LIMIT 20;

-- Occupations with corresponding wages

SELECT 
occ_title AS occupation, ROUND(AVG(hourly_mean_wage), 2) AS avg_hourly_wage,
ROUND(AVG(annual_mean_wage), 2) AS avg_annual_wage
FROM analytics_wages
GROUP BY occ_title
ORDER BY avg_annual_wage DESC;


-- Displays amount of occupations with particular wage

SELECT 
	annual_mean_wage, 
	COUNT(*) AS occupation_count
FROM analytics_wages
GROUP BY annual_mean_wage
ORDER BY annual_mean_wage;

-- Displays amount of employment in each industry
SELECT 
	naics_title AS industry, 
	SUM(amount_employed) AS total_employed
FROM analytics_wages
GROUP BY naics_title
ORDER BY total_employed DESC;





