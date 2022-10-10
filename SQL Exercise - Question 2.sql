--Second Question :
--Step 1: We are going to match the job post with the freelancer's registration that occured in 2019 within 1 month of registration
--Assumption: The month has 30 days
WITH freelancer_registration_2019 AS 
(
	SELECT
	 p.freelancer_id,
	 j.job_post_category,
	 j.post_date,
	 j.hire_date,
	 f.registration_date
	 --DATEDIFF(DAY,f.registration_date,j.hire_date) as days_diff
	FROM payment p
	LEFT JOIN job_post j ON j.job_post_id=p.job_post_id
	LEFT JOIN freelancer f ON f.freelancer_id=p.freelancer_id
	WHERE 
		--Registrations that occured in 2019
		YEAR(f.registration_date)=2019
		--Within 1 month of registration
		and DATEDIFF(DAY,f.registration_date,j.hire_date)<30
),
--Step 2: Then, we need to get the list of the freelancer with two or more categories
freelancer_number_categories AS 
(
	SELECT
	 freelancer_id,
	 COUNT(DISTINCT job_post_category) as number_categories
	FROM freelancer_registration_2019
	GROUP BY
	 freelancer_id
	--With the following HAVING statement, we filter the freelancer with two or more categories
	HAVING COUNT(DISTINCT job_post_category)>=2
)
--Step 3: Finally, we count the number of hired freelancer with two or more categories within a month of registration
SELECT 
 COUNT(*) AS number_freelancer_two_or_more_categories 
FROM freelancer_number_categories