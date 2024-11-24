SELECT 
   TO_CHAR(month, 'YYYY-MM') AS month
  ,stage_id AS funnel_step_id
  ,stage_name AS funnel_step
  ,COALESCE(deals_count, 0) AS deals_count
  ,COALESCE(ROUND(avg_users_per_deal::numeric, 2), 0) AS avg_users_per_deal
  ,COALESCE(ROUND(conversion_rate::numeric, 2), 0) AS converstion_rate
FROM {{ ref('t_sales_funnel_monthly_columns') }}
-- ORDER BY 
--    month 
--   ,stage_id