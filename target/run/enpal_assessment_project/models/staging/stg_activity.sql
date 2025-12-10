
  create view "postgres"."public_pipedrive_analytics"."stg_activity__dbt_tmp"
    
    
  as (
    

select
    activity_id::int as activity_id,
    "type" as "type",
    assigned_to_user as assigned_to_user,
    deal_id as deal_id,
    done as done,
    due_to::timestamp as due_to
from "postgres"."public"."activity"
  );