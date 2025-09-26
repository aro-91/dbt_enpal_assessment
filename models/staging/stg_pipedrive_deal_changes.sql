{{ config(materialized='view') }}

with src as (
  select
    deal_id::bigint,
    changed_field_key,
    new_value,
    change_time::timestamp as changed_at
  from {{ source('pipedrive','deal_changes') }}
)
select * from src