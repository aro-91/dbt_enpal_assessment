{{ config(materialized='view') }}

select
    stage_id::int as stage_id,
    stage_name as stage_name
from {{ source('crm', 'stages') }}