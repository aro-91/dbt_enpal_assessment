
  
    

  create  table "postgres"."pipedrive_analytics"."rep_sales_funnel_monthly__dbt_tmp"
  
  
    as
  
  (
    -- Monthly sales funnel reporting model





with deals AS (

    select month_year,
           kpi_name,
           funnel_step,
       count(distinct deal_id) deals_count
from "postgres"."pipedrive_analytics"."int_activity_deals_funnel"

group by month_year,
         kpi_name,
         funnel_step
)


select mfm.month_year as month,
       mfm.kpi_name,
       mfm.funnel_step,
       coalesce(d.deals_count,0) deals_count
from "postgres"."pipedrive_analytics"."int_month_funnel_matrix" mfm 
left join deals d

on mfm.month_year = d.month_year
and mfm.funnel_step = d.funnel_step
  );
  