
  create view "postgres"."public_pipedrive_analytics"."stg_activity_types__dbt_tmp"
    
    
  as (
    

select
    id::int as id,
    "name" as name,
    active as active,
    "type" as type
from "postgres"."public"."activity_types"
  );