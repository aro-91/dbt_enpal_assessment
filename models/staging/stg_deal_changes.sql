{{ config(materialized='view') }}

with src as (
  select * from {{ source('postgres_public','deal_changes') }}
),

stg_deal_changes as (
  select
        deal_id::bigint as deal_id
      , change_time
      , changed_field_key
      , new_value
    FROM src
    WHERE deal_id IS NOT NULL
)

select * from stg_deal_changes