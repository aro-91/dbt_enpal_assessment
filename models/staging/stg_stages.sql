{{ config(materialized='view') }}

with src as (
  select * from {{ source('postgres_public','stages') }}
),

stg_stages as (
  select
    stage_id::int as stage_id,
    stage_name as stage_name
  from src
)

select * from stg_stages