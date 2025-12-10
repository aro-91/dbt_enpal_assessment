{{ config(materialized='view') }}

select
    id::int as id,
    field_key as field_key,
    "name" as field_name,
    field_value_options as field_value_options
from {{ source('crm', 'fields') }}