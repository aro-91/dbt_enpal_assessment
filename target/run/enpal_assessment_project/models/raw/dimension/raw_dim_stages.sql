
  
    

  create  table "postgres"."pipedrive_analytics"."raw_dim_stages__dbt_tmp"
  
  
    as
  
  (
    -- Staging model for stages
-- Loads stages data



select
    stage_id,
    stage_name,
    current_date as load_date
from "postgres"."public"."stages"
  );
  