{{
    config(materialized='view')
}}

with source as (
    select * from {{ source('pipedrive', 'activity_types') }}
)

select
    id              as activity_type_id,
    name            as activity_type_name,
    active::boolean as is_active,
    type            as type_key
from activity_types
