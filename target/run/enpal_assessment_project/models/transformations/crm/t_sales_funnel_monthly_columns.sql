
  create view "postgres"."public_crm"."t_sales_funnel_monthly_columns__dbt_tmp"
    
    
  as (
    WITH calendar_ AS (
-- creating a time dimension
SELECT DISTINCT
   month
FROM "postgres"."public"."calendar_" --public.calendar_
WHERE month BETWEEN '2024-01-01' AND DATE_TRUNC('month', current_date)
)
, funnel_steps AS (
-- getting the current funnel steps
SELECT DISTINCT stage_id, stage_name 
FROM "postgres"."public_crm"."t_deal_funnel_events" 
)
, funnel_events AS (
-- all the funnel events
SELECT DISTINCT
   deal_id
  ,change_time AS event_time
  ,LEAD(change_time) OVER (PARTITION BY deal_id ORDER BY change_time) AS next_event_time
  ,DATE_TRUNC('month', DATE(change_time)) AS event_month
  ,stage_id 
  ,stage_name
FROM "postgres"."public_crm"."t_deal_funnel_events"
)
, cross_join_days_steps AS (
-- building the catalog of month and funnel step
SELECT *
FROM calendar_
CROSS JOIN funnel_steps
)
, kpi_deal_count AS (
SELECT
   event_month
  ,stage_id
  ,stage_name
  ,COUNT(DISTINCT deal_id) deals_count
FROM funnel_events 
GROUP BY
  event_month
 ,stage_id
 ,stage_name
)
, kpi_avg_users AS (
SELECT
   stage_id
  ,event_month
  ,AVG(users_count) AS avg_users_per_deal
FROM (
    SELECT
       fe.deal_id,
       fe.stage_id,
       fe.event_month,
       COUNT(DISTINCT ud.user_id) AS users_count
    FROM funnel_events fe
    LEFT JOIN "postgres"."public_crm"."t_user_deal_events" ud
      ON ud.deal_id = fe.deal_id  AND ud.change_time BETWEEN fe.event_time AND fe.next_event_time
    GROUP BY 
       fe.deal_id
      ,fe.stage_id
      ,fe.event_month
) users_per_deal
GROUP BY 
   stage_id
  ,event_month
)
, draft_funnel AS (
SELECT DISTINCT
   s.month 
  ,s.stage_id
  ,s.stage_name 
  ,dc.deals_count::FLOAT AS deals_count
  ,COALESCE(au.avg_users_per_deal, 0) AS avg_users_per_deal
FROM cross_join_days_steps s
LEFT JOIN funnel_events fe ON s.month = fe.event_month  AND s.stage_id = fe.stage_id
LEFT JOIN kpi_deal_count dc ON s.month = dc.event_month AND s.stage_name = dc.stage_name
LEFT JOIN kpi_avg_users au ON s.month = au.event_month AND s.stage_id = au.stage_id
)
, funnel_with_conversion_rate AS (
-- calculating conversion rate but not taking into consideration steps 2.1 and 3.1 (they are optional?)
SELECT
   month 
  ,stage_id
  ,stage_name
  ,deals_count
  ,prev_deals_count
  ,avg_users_per_deal
  ,CASE
     WHEN stage_id NOT IN (2.1, 3.1) 
       THEN deals_count / NULLIF(prev_deals_count,0) * 100 
   END AS conversion_rate
FROM (
	SELECT *, 
	  LAG(CASE WHEN stage_id NOT IN (2.1, 3.1) THEN deals_count ELSE NULL END)  
	    OVER (PARTITION BY month /* IGNORE NULLS */ 
	    -- ordering the stages to get the previous steps ignoring 2.1 and 3.1
	            ORDER BY
	              CASE WHEN stage_id IN (2.1, 3.1) THEN NULL ELSE stage_id END 
	  ) prev_deals_count
	FROM draft_funnel
)
)
SELECT
   month 
  ,stage_id
  ,stage_name
  ,deals_count
  ,avg_users_per_deal
  ,conversion_rate -- ignoring [optional] steps
FROM funnel_with_conversion_rate
-- ORDER BY month, stage_id
  );