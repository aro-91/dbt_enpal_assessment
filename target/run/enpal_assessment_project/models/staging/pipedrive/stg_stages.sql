
  
    

  create  table "postgres"."public_staging"."stg_stages__dbt_tmp"
  
  
    as
  
  (
    SELECT *
FROM "postgres"."public"."stages"
  );
  