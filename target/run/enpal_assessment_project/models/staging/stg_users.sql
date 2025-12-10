
  create view "postgres"."public_pipedrive_analytics"."stg_users__dbt_tmp"
    
    
  as (
    

select
    id::int as id,
    "name" as name,
    email as email,
    modified::timestamp as modified
from "postgres"."public"."users"
  );