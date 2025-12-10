
  create view "postgres"."public_pipedrive_analytics"."stg_deal_changes__dbt_tmp"
    
    
  as (
    

select
    deal_id::int as deal_id,
    changed_field_key as changed_field_key,
    change_time::timestamp as change_time,
    new_value as new_value
from "postgres"."public"."deal_changes"
  );