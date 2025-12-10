with source as (
    select * from {{ source('postgres_public', 'deal_changes') }}
),

staged as (
    select
        deal_id,
        change_time as change_timestamp,
        changed_field_key as field_key,
        new_value
    from source
)

select * from staged

