{{ config(materialized='view') }}

select
    id::int as id,
    "name" as name,
    active as active,
    "type" as type
from {{ source('crm', 'activity_types') }}