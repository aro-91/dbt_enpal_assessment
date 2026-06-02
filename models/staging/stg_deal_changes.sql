{{
    config(materialized='view')
}}

with source as (
    select * from {{ source('pipedrive', 'deal_changes') }}
),

renamed as (
    select
        deal_id,
        change_time::timestamp       as changed_at,
        changed_field_key            as field_key,
        new_value                    as new_value
    from source
)

select * from renamed
