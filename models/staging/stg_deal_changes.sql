{{ config(materialized='view') }}

select
    deal_id::int as deal_id,
    changed_field_key as changed_field_key,
    change_time::timestamp as change_time,
    new_value as new_value
from {{ source('crm', 'deal_changes') }}