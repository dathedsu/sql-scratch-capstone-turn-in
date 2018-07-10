WITH months AS (
  SELECT 
    '2017-01-01' AS first_day, 
    '2017-01-31' AS last_day 
  UNION 
  SELECT 
    '2017-02-01' AS first_day, 
    '2017-02-28' AS last_day 
  UNION 
  SELECT 
    '2017-03-01' AS first_day, 
    '2017-03-31' AS last_day
),

cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),

status AS (
  SELECT 
    id,
    first_day AS month,
    last_day,
    CASE
      WHEN subscription_start < first_day AND
      segment = 87
    THEN 1 ELSE 0
    END
    AS is_active_87,
    CASE
      WHEN subscription_start < first_day AND
      segment = 30
    THEN 1 ELSE 0
    END
    AS is_active_30,
    --/*
    CASE
      WHEN subscription_end BETWEEN first_day AND last_day
      AND segment = 87
    THEN 1 ELSE 0
    END
    AS is_canceled_87,
    CASE
      WHEN subscription_end BETWEEN first_day AND last_day
      AND segment = 30
    THEN 1 ELSE 0
    END
    AS is_canceled_30
    --*/
  FROM cross_join
),

status_aggregate AS (
  SELECT
    month,
    SUM(is_active_87) AS sum_active_87,
  	SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP by month
),

churn_rate AS (
  SELECT 
    month, 
    1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
    1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
  FROM status_aggregate
),

churn_rate_total AS (
	SELECT
  	month,
  	1.0 * (sum_canceled_87 + sum_canceled_30) /
  	(sum_active_87 + sum_active_30) 
  	AS churn_rate_total
  FROM status_aggregate
),

churn_rate_avg AS (
	SELECT 
  	AVG(churn_rate_87) AS churn_average_87,
  	AVG(churn_rate_30) AS churn_average_30
  FROM churn_rate
)

/*
SELECT MIN(subscription_start) AS 'First Subscription', MAX(subscription_end) AS 'Last Cancellation'
FROM subscriptions;

SELECT MIN(subscription_end) AS 'First_Cancellation'
FROM subscriptions;
*/

/*
SELECT *
FROM churn_rate_total;
*/

/*
SELECT *
FROM churn_rate
*/

/*
SELECT *
FROM status_aggregate;
*/

--Below is an answer to the bonus question "How would you modify this code to support a large number of segments?"


WITH months AS (
	SELECT 
    '2017-01-01' AS first_day, 
    '2017-01-31' AS last_day 
  UNION 
  SELECT 
    '2017-02-01' AS first_day, 
    '2017-02-28' AS last_day 
  UNION 
  SELECT 
    '2017-03-01' AS first_day, 
    '2017-03-31' AS last_day
),

status AS (
	SELECT
		id,
		first_day AS month,
		segment,

	CASE
		WHEN subscription_start < first_day
		THEN 1 
		ELSE NULL 
	end AS active,

	CASE
		WHEN subscription_end BETWEEN first_day
		AND last_day
		THEN 1 
		ELSE NULL 
	end AS canceled

	FROM subscriptions 
	JOIN months ON last_day > subscription_start
	OR 
	first_day < subscription_end
)

SELECT
	segment,
	month,
	1.0 * SUM(canceled) / SUM(active)
	AS churn_rate
FROM status
GROUP BY segment, month;



                                                      
