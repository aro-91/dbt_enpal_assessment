
  create or replace   view pipedrive_analytics.staging.stg_fields
  
  
  
  
  as (
    with source as (
    select * from pipedrive_analytics.raw.fields
),
renamed as (
    select
        id as field_id,
        field_key,
        name as field_name,
        field_value_options
    from source
)
select * from renamed
  );

