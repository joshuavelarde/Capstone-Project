/*
Which top 10 skills are most frequently requested for Data Analyst positions in Sydney?

Methodology:
- Calculate the frequency of each skill mentioned in the job postings
- Identify the top 10 most frequently requested skills
- Combine the job table with the skill table

Rationale:
This query aims to understanding the top 10 in-demand data analyst skills in Australia
which empowers job seekers, educators, and employers to make informed decisions 
about career development, training, and talent acquisition.
*/


SELECT
	sd.skills AS skill_name,
	sd.type AS skill_type,
	COUNT (sd.skill_ID) AS skill_frequency -- COUNT is used to add the frequency of each skill.
FROM
	skills_dim AS sd

JOIN skills_job_dim AS sjd ON sjd.skill_id = sd.skill_id
JOIN job_postings_fact AS jpf ON jpf.job_id = sjd.job_id

WHERE
	job_title_short = 'Data Analyst'
AND job_location LIKE '%Sydney%'

GROUP BY
	sd.skill_id  -- GROUP BY clause is used to aggregate data by job tier
ORDER BY
	skill_frequency DESC -- ORDER BY is applied to show results by skill_count in descending order
LIMIT
	10; -- LIMIT is used to only show the top 10 skills in the result