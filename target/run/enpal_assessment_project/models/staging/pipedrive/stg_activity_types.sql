
  
    

  create  table "postgres"."public_staging"."stg_activity_types__dbt_tmp"
  
  
    as
  
  (
    SELECT
   id
  ,name
  ,CASE WHEN active = 'Yes' THEN TRUE ELSE FALSE END AS active
  ,type
FROM "postgres"."public"."activity_types"
  );
  