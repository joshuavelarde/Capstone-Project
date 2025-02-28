/*
Question 4:
Which top 5 companies are hiring the most Data Analysts in Australia, 
and what are the top 3 skills they're requesting?

Methodology:
- Count the number of "Data Analyst" job postings for each company in Australia.
- Calculate the frequency of each skill requested in their "Data Analyst" job postings.
- Display the top 3 skills requested by these top 5 companies, along with their skill frequencies.

Rationale:
This query identifies the top 5 Australian companies actively hiring 
Data Analysts and reveals the top 3 skills they demand, providing 
crucial insights for job seekers and educators. It offers a focused 
view of current employer preferences in the Australian Data Analyst market.
*/


WITH top_aussie_companies AS (
SELECT 
	cd.company_id,
	cd.name AS company_name,
	COUNT(jpf.job_id) AS job_frequency,
	ROW_NUMBER() OVER (ORDER BY COUNT(jpf.job_id) DESC) AS company_rank -- assigns a rank to each company
FROM
	company_dim AS cd
JOIN job_postings_fact AS jpf ON jpf.company_id = cd.company_id
WHERE
	job_title_short = 'Data Analyst'
	AND job_country = 'Australia'
GROUP BY
	company_name, cd.company_id
ORDER BY
	job_frequency DESC
LIMIT
	5
),
ranked_skills AS (
SELECT 
	tac.company_name,
	sd.skills,
	COUNT(sd.skills) AS skill_frequency,
	ROW_NUMBER() OVER (PARTITION BY tac.company_name ORDER BY COUNT(sd.skills) DESC) AS skill_rank -- assigns a rank to each skill within each company
FROM
	top_aussie_companies AS tac
JOIN job_postings_fact AS jpf ON tac.company_id = jpf.company_id
JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
WHERE tac.company_rank <= 5 -- demonstrates less than or equal to operator to identify the top 5 companies
GROUP BY
	tac.company_name, sd.skills
)

SELECT
	company_name,
	skills AS skill,
	skill_frequency
FROM
	ranked_skills
WHERE
	skill_rank <= 3
ORDER BY
	company_name ASC, skill_frequency DESC;