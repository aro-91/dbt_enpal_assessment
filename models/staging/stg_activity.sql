{{ config(materialized='view') }}

with src as (
    select * from {{ source('postgres_public','activity') }}
),

stg_activity as (
    select
        activity_id::bigint as activity_id,
        type as activity_type_key,
        assigned_to_user::bigint as user_id,
        deal_id::bigint as deal_id,
        done as is_done,
        due_to as due_ts
    from src
)

SELECT * from stg_activity

