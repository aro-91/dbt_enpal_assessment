
  create view "postgres"."public_pipedrive_analytics"."stg_stages__dbt_tmp"
    
    
  as (
    

select
    stage_id::int as stage_id,
    stage_name as stage_name
from "postgres"."public"."stages"
  );