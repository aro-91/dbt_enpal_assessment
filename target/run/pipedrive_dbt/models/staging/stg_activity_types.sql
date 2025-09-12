
  create or replace   view pipedrive_analytics.staging.stg_activity_types
  
  
  
  
  as (
    with source as (
    select * from pipedrive_analytics.raw.activity_types
),
renamed as (
    select
        id as activity_type_id,
        name as activity_name,
        active as is_active,
        type as activity_type_key
    from source
)
select * from renamed
  );

