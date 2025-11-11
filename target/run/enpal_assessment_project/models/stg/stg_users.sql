
  create view "postgres"."public_pipedrive_analytics"."stg_users__dbt_tmp"
    
    
  as (
    

select
    id as user_id,
    name as user_name,
    email
from "postgres"."public"."users"
  );