
  
    

  create  table "postgres"."public_staging"."stg_fields__dbt_tmp"
  
  
    as
  
  (
    SELECT
   id
  ,field_key
  ,name
  ,opt->>'id' AS option_id
  ,opt->>'label' AS option
FROM "postgres"."public"."fields" 
 LEFT JOIN LATERAL jsonb_array_elements(field_value_options) opt ON 3=3
  );
  