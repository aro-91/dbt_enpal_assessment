
  create view "postgres"."public_pipedrive_analytics"."stg_fields__dbt_tmp"
    
    
  as (
    

select
    id::int as id,
    field_key as field_key,
    "name" as field_name,
    field_value_options as field_value_options
from "postgres"."public"."fields"
  );