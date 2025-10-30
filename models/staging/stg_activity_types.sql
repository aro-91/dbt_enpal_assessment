{{ config(materialized='view') }}


with src as (
select * from postgres.public.activity_types
)
, stg_activity_types as (
    SELECT
        id AS activity_type_id, 
        name AS activity_type_name
        , type AS activity_type_short
        , active AS is_activity_type_active
    FROM src
    WHERE TRUE
        AND id IS NOT NULL
)
select * from stg_activity_types


