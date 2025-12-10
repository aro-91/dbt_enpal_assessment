{{
    config(
        materialized='view'
    )
}}

-- Staging model for activity types

SELECT
    id AS activity_type_id,
    name AS activity_name,
    active,
    type AS activity_type_code
FROM {{ source('postgres_public', 'activity_types') }}
WHERE id IS NOT NULL
