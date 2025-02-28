/*
Question 2:
What are the current salary ranges for mid-level and senior-level job openings in 
Australia, and how do these ranges compare to the global average of the same levels?

Methodology:
- Filter job postings by country and mid-to-senior level titles.
- Calculate minimum and maximum salaries for each job level in Australia.
- Only provide the roles with salary information showing both yearly or hourly.
- Calculate the global average salaries for each job level.

Rationale:
This query compares Australia Data Analyst salaries to the worldwide average, 
by experience level, to inform job seekers about compensation in the Australian market.
*/


WITH job_levels AS (
	SELECT
		job_title,
		salary_year_avg,
		salary_hour_avg,
		CASE -- Classifies roles as senior or mid-level based on job title keywords.
			WHEN job_title LIKE '%Senior%'
	 		  OR job_title LIKE '%Lead%'
			  OR job_title LIKE '%sr%'
			  OR job_title LIKE '%Principal%'
			  OR job_title LIKE '%Manager%'
			  OR job_title LIKE '%Director%'
			THEN 'senior titled roles'
			ELSE 'mid level roles'
		END AS job_tier,
		job_location,
		job_country
	FROM
		job_postings_fact
	WHERE 
		(salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL)
		AND NOT (job_title LIKE '%junior%'
			  OR job_title LIKE '%entry%'
			  OR job_title LIKE '%no experience%')
),

national_salaries AS (
	SELECT
		job_tier,
		MIN(salary_year_avg) AS min_yearly_salary,
		MAX(salary_year_avg) AS max_yearly_salary,
		MIN(salary_hour_avg) AS min_hourly_salary,
		MAX(salary_hour_avg) AS max_hourly_salary  -- MIN & MAX aggregate function is used to calculate minimum and maximum yearly salary.
	FROM 
		job_levels
	WHERE
		job_country LIKE '%Australia%'
	GROUP BY
		job_tier
),
global_avg_salary AS (
	SELECT
    job_tier,
    ROUND(AVG(salary_year_avg), 2) AS avg_yearly_salary, -- ROUND: Rounds average yearly salary to two decimal places. AVG: Calculates average yearly salary.
    ROUND(AVG(salary_hour_avg), 2) AS avg_hourly_salary -- ROUND: Rounds average hourly salary to two decimal places. AVG: Calculates average hourly salary.
	FROM 
		job_levels
	WHERE 
		job_country != 'Australia'
	GROUP BY
		job_tier
)
SELECT 
	n.job_tier,
	n.min_yearly_salary AS MIN_Australian_Annual_Salary,
	n.max_yearly_salary AS MAX_Australian_Annual_Salary,
	n.min_hourly_salary AS MIN_Australian_Hourly_Salary,
	n.max_hourly_salary AS MAX_Australian_Hourly_Salary,
	g.avg_yearly_salary AS AVG_Global_Annual_Salary,
	g.avg_hourly_salary AS AVG_Global_Hourly_Salary	
FROM 
	national_salaries AS n -- Used to create a shorter alias 'n' for the 'national_salaries' CTE, improving readability.
JOIN
	global_avg_salary AS g ON n.job_tier = g.job_tier;