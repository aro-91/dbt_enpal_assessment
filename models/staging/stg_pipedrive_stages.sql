{{ config(materialized='view') }}

with src as (
  select
    stage_id::bigint,
    stage_name
  from {{ source('pipedrive','stages') }}
)
select * from src