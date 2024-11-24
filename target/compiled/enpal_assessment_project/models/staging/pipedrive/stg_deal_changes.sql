SELECT
   deal_id
  ,change_time
  ,changed_field_key
  ,new_value
FROM "postgres"."public"."deal_changes"


  WHERE change_time > (SELECT MAX(change_time) FROM "postgres"."public_staging"."stg_deal_changes")
