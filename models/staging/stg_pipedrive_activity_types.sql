{{ config(materialized='view') }}


with src as (
  select
    id::bigint,
    name,
    active::boolean,
    type
  from {{ source('pipedrive','activity_types') }}
)
select * from src