
  
    

  create  table "postgres"."public_pipedrive_analytics"."rep_sales_funnel_monthly__dbt_tmp"
  
  
    as
  
  (
    

select *
from "postgres"."public_pipedrive_analytics"."int_deal_stage_progression"
order by month, kpi_name
  );
  