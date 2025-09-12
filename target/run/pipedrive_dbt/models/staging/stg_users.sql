
  create or replace   view pipedrive_analytics.staging.stg_users
  
  
  
  
  as (
    with source as (
    select * from pipedrive_analytics.raw.users
),
renamed as (
    select
        id as user_id,
        sha2(name) as user_name_hashed,
        sha2(email) as user_email_hashed,
        modified::timestamp as modified_timestamp
    from source
)
select * from renamed
  );

