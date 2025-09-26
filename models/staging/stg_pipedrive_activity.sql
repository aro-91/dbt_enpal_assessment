{{ config(materialized='view') }}

with src as (
  select
    activity_id::bigint,
    type,
    deal_id::bigint,
    due_to::timestamp as due_at,
    done::boolean
  from {{ source('pipedrive','activity') }}
)
select * from src