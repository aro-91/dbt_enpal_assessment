
  
    

  create  table "postgres"."pipedrive_analytics"."raw_dim_activity_types__dbt_tmp"
  
  
    as
  
  (
    -- Staging model for Activity type
-- Loads activity type data



select
    id,
    name,
    active,
    type,
    current_date as load_date
from "postgres"."public"."activity_types"
  );
  