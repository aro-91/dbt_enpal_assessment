
  create view "postgres"."public"."test_model__dbt_tmp"
    
    
  as (
    SELECT *
FROM "postgres"."public"."activity"
  );