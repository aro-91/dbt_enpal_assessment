{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

with source as (
    select
        deal_id,
        change_time::timestamp as change_timestamp,
        changed_field_key,
        new_value::string as new_value
    from {{ source('raw', 'deal_changes') }}
    {% if is_incremental() %}
    where change_time > (select coalesce(max(change_timestamp), '2024-01-01'::timestamp) from {{ this }})
    {% endif %}
)
select * from source
