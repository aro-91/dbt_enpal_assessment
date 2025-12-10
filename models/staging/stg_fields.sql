{{
    config(
        materialized='view'
    )
}}

-- Staging model for fields metadata

SELECT
    id AS field_id,
    field_key AS field_key,
    name AS field_name,
    field_value_options AS field_value_options
FROM {{ source('postgres_public', 'fields') }}
WHERE id IS NOT NULL