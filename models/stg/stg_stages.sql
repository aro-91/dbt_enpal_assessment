{{ config(materialized='view') }}

select
    stage_id,
    stage_name
from {{ source('postgres_public', 'stages') }}
