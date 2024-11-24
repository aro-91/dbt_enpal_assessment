SELECT
   TO_CHAR(month, 'YYYY-MM') AS month
  ,stage_id AS funnel_step_id
  ,stage_name AS funnel_step
  ,funnel_kpi
  ,COALESCE(CASE WHEN funnel_kpi IN ('avg_users_per_deal','conversion_rate')
     THEN ROUND(kpi_value::numeric, 2)
     ELSE kpi_value
   END,0) AS kpi_value
FROM "postgres"."public_crm"."t_sales_funnel_monthly_rows"
-- ORDER BY 
--    month 
--   ,stage_id
--   ,funnel_kpi