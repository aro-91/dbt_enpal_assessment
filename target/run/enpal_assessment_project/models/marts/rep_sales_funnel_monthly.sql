
  
    

  create  table "postgres"."public_pipedrive_analytics"."rep_sales_funnel_monthly__dbt_tmp"
  
  
    as
  
  (
    select 
    date_trunc('month', change_time)::date as "month",
    stage_name as kpi_name,
    stage_id as funnel_step,
    count(*) as deals_count
from "postgres"."public_pipedrive_analytics"."dwh_deal_changes_activity"
group by 1, 2, 3
order by 1 asc, 3 asc
  );
  