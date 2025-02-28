/*
Question 5:
What are the top 2 Data Analyst skills with the fastest-growing 
demand among Australia's top 20 hiring companies in 2023?

Methodology:
- Find Australia's top 20 Data Analyst hiring companies in 2023.
- Divide 2023 into two 6-month segments (Jan-Jun and Jul-Dec).
- Calculate the skill frequency for each company during each 6-month segment.
- Identify the 2 skills with the greatest frequency increase.
- Display the company name, skill, and skill frequency for the second 6-month segment.

Rationale:
This query gives insight into the top 2 most in-demand 
Data Analyst skills in Australia for the 2023 calendar year.
*/


WITH top_aussie_companies_2023 AS (
SELECT 
	cd.name AS company_name,
	cd.company_id,
	COUNT(jpf.job_id) AS job_frequency,
	ROW_NUMBER() OVER (ORDER BY COUNT(jpf.job_id) DESC) AS company_rank
FROM
	company_dim AS cd
JOIN job_postings_fact AS jpf ON jpf.company_id = cd.company_id
WHERE
	job_title_short = 'Data Analyst'
	AND job_country = 'Australia'
	AND EXTRACT(YEAR FROM job_posted_date) = 2023 -- EXTRACT function is used to filter 2023 job postings
GROUP BY
	company_name, cd.company_id
ORDER BY
	job_frequency DESC
LIMIT
	20
),

skill_numbers AS (
	SELECT
		tac.company_name,
		sd.skills,
		COUNT(sd.skills) AS skill_frequency,
		CASE 
			WHEN jpf.job_posted_date >= '2023-07-01' THEN 'Jul-Dec' 
			ELSE 'Jan-Jun' 
		END AS time_segment
	FROM
		top_aussie_companies_2023 AS tac
	JOIN job_postings_fact AS jpf ON jpf.company_id = tac.company_id
	JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
	JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
	WHERE
		tac.company_rank <= 20
		AND jpf.job_posted_date BETWEEN '2023-01-01' AND '2023-12-31' -- BETWEEN operator is used to filter starting and ending range of dates in 2023
	GROUP BY
		tac.company_name, sd.skills, time_segment

),

skill_frequency_growth AS (
    SELECT
        company_name,
        skills,
        COALESCE(SUM(CASE WHEN time_segment = 'Jul-Dec' THEN skill_frequency ELSE 0 END),0) - 
        COALESCE(SUM(CASE WHEN time_segment = 'Jan-Jun' THEN skill_frequency ELSE 0 END),0) AS frequency_increase -- COALESCE function used to prevent NULL values ensuring accurate comparison
    FROM
        skill_numbers
    GROUP BY
        company_name, skills
    HAVING 
		COALESCE(SUM(CASE WHEN time_segment = 'Jul-Dec' THEN skill_frequency ELSE 0 END),0) > 0 -- HAVING clause used to filter an aggregation
),

ranked_skills AS (
	SELECT
		company_name,
		skills,
		frequency_increase,
		ROW_NUMBER() OVER (PARTITION BY company_name ORDER BY frequency_increase DESC) AS skill_rank
	FROM
		skill_frequency_growth
)

SELECT 
	company_name,
	skills,
	frequency_increase AS skills_needed_increase
FROM
	ranked_skills
WHERE
	skill_rank <= 2
ORDER BY
	company_name ASC, skills_needed_increase DESC;