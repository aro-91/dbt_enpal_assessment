
{{ config(materialized='view') }}

with src as (
  select * from {{ source('postgres_public','users') }}
),

stg_users as (
  select
      id::int as user_id,
      name as user_name,
      email as user_email,
      modified as user_created_at
  from src
)

select * from stg_users

