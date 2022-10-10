--Third Question :
--Step 1: We are going to match the job post with the freelancer's registration that occured in 2019
--Assumption 1: If the job post has a hire_date, we consider that job post as a filled position
--Assumption 2: We assume that the joins are not going to generate data replication
-- Also, we are creating a boolean field which 
	--1 means meet the criterion 'filled within 7 days of job post and by a freelancer registered in the US'
	--0 means doesn't meet the previous criterion

WITH job_post_2019 AS 
(
	SELECT
	 f.freelancer_id,
	 j.job_post_category,
	 j.post_date,
	 j.hire_date,
	 f.registration_date,
	 f.registration_country,
	 DATEDIFF(DAY,j.post_date,j.hire_date) AS filled_days,
	 CASE
		WHEN 
		-- Filled with 7 days of job post
		DATEDIFF(DAY,j.post_date,j.hire_date)<7
		AND
		--Freelancer registered in the US
		f.registration_country='US'
		THEN 1
		ELSE 0
	 END AS flg_criterion
	FROM job_post j
	LEFT JOIN payment p ON j.job_post_id=p.job_post_id
	LEFT JOIN freelancer f ON f.freelancer_id=p.freelancer_id
	WHERE YEAR(j.post_date)=2019
)
--Step 2: Calculate the share of total job post in 2019
SELECT 
	SUM(flg_criterion)*100/COUNT(*) AS US_filled_jobs_share 
FROM job_post_2019