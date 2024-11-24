
  create view "postgres"."public_crm"."t_deal_lost_reasons__dbt_tmp"
    
    
  as (
    SELECT
   dc.deal_id
  ,dc.change_time 
  ,f.option AS lost_reason    
FROM "postgres"."public_staging"."stg_deal_changes" dc
LEFT JOIN "postgres"."public_staging"."stg_fields" f ON dc.changed_field_key = f.field_key 
  AND dc.new_value = f.option_id 
WHERE changed_field_key = 'lost_reason'
  );