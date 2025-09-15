
  
    

  create  table "postgres"."pipedrive_analytics"."raw_fact_deal_changes__dbt_tmp"
  
  
    as
  
  (
    -- Staging model for deal changes
-- Cleans and standardizes deal change data




with cleaned as (
   select
       deal_id,
       change_time,
       changed_field_key,
       new_value,
       -- Date derived fields
       extract(month from change_time) as change_month,
       extract(year from change_time) as change_year,
       to_char(date_trunc('month', change_time), 'yyyy-mm') as change_month_year,
       current_date AS load_date
   from "postgres"."public"."deal_changes"
)


select * 
from cleaned
  );
  