--First Question :
--Step 1: We are going to match the payment with the freelancer's job category in 2019
WITH freelancer_payment_2019 AS 
(
	SELECT
	 p.freelancer_id,
	 p.payment_amount,
	 j.job_post_category,
	 p.payment_date
	FROM payment p
	LEFT JOIN job_post j ON j.job_post_id=p.job_post_id
	LEFT JOIN freelancer f ON f.freelancer_id=p.freelancer_id
	WHERE YEAR(p.payment_date)=2019
),

--Step 2: Then, we group by freelancer and category in order to get the total payment amount by year
freelancer_earnings AS
(
	SELECT
	 freelancer_id,
	 job_post_category,
	 sum(payment_amount) AS payment_amount_2019
	FROM freelancer_payment_2019
	GROUP BY freelancer_id, job_post_category
),

--Step 3: Then, we rank the payment_amount by post_category and freelancer_id. 
--        Also, we filter the category with the highest 2019 earning
list_freelancer_earnings_rank AS
(
	SELECT * FROM (
		SELECT
		 freelancer_id,
		 job_post_category,
		 payment_amount_2019,
		 RANK ()	OVER (
					PARTITION BY freelancer_id
					ORDER BY payment_amount_2019 DESC
		 ) AS rank_position
		FROM freelancer_earnings) ranking
	--With the following WHERE statement, we stick with the freelancer with the highest category in Writing
	WHERE rank_position=1 AND job_post_category='Writing'
)

--Step 4: Finally, we calculate the average monthly earnings across all categories for 2019 using the list of freelancers
-- Assumption: Calculation of the monthly average only applies to isolated month (not consider the full range of period). 
-- Ex: A freelancer can work in February and December. We average the two months

SELECT
	freelancer_id,
	AVG(monthly_earnings) AS avg_monthly_earnings_2019
FROM 
(
	SELECT
	 freelancer_id,
	 MONTH(payment_date) AS month_number,
	 SUM(payment_amount) AS monthly_earnings
	FROM freelancer_payment_2019
	WHERE 
	 --We filter the freelancer that belong to the previous list
	 freelancer_id IN (SELECT freelancer_id FROM list_freelancer_earnings_rank)
	GROUP BY 
	 freelancer_id,
	 MONTH(payment_date)
) monthly_payment
GROUP BY
	freelancer_id