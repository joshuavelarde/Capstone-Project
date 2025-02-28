/*
Question 1:
How many Data Analyst positions are available in Australia that are not senior-level and offer remote work?

Methodology:
- Identify job postings located in Australia.
- Exclude job titles containing "Senior" or similar keywords (e.g., "Lead," "Manager," "Director," etc.).
- Filter for job postings that offer remote work options (e.g., work from home, work from anywhere).

Rationale:
This query aims to identify Australian remote work opportunities for entry to mid-level Data Analysts.
*/


WITH senior_level_roles AS ( -- CTE: Identifies senior-level roles based on job title keywords.
    SELECT job_title 
    FROM job_postings_fact
	WHERE job_title LIKE '%Senior%'
       OR job_title LIKE '%Lead%'
       OR job_title LIKE '%Principal%'
       OR job_title LIKE '%Manager%'
       OR job_title LIKE '%Director%'
)

SELECT 
    COUNT(*) AS entry_mid_level_jobs -- Counts the number of entry/mid-level Data Analyst jobs.
FROM 
    job_postings_fact
WHERE 
    job_title_short LIKE 'Data Analyst' -- LIKE: Filters for Data Analyst job titles.
    AND job_country = 'Australia'
    AND job_title NOT IN (SELECT job_title FROM senior_level_roles) -- Subquery: Excludes senior-level job titles.
    AND (job_location LIKE '%Anywhere%' OR job_work_from_home IS TRUE);