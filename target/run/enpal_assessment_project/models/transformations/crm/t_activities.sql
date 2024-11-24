
  create view "postgres"."public_crm"."t_activities__dbt_tmp"
    
    
  as (
    SELECT 
   a.activity_id
  ,ty.name AS activity_name
  ,a.assigned_to_user 
  ,a.deal_id 
  ,a.done AS is_done
  ,a.due_to
--  ,ty.active 
FROM "postgres"."public_staging"."sn_activities" a
  LEFT JOIN "postgres"."public_staging"."stg_activity_types" ty ON a.type = ty.type
  );