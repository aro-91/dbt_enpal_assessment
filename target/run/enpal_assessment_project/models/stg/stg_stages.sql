
  create view "postgres"."public_pipedrive_analytics"."stg_stages__dbt_tmp"
    
    
  as (
    

select
    stage_id,
    stage_name
from "postgres"."public"."stages"
  );