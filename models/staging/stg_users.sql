{{
    config(
        materialized='view'
    )
}}

-- Staging model for users

SELECT
    id AS user_id,
    name AS user_name,
    email,
    modified::timestamp AS last_modified
FROM {{ source('postgres_public', 'users') }}
WHERE id IS NOT NULL
