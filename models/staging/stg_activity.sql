{{
    config(
        materialized='view'
    )
}}

-- Staging model for activities with proper type handling

SELECT
    activity_id,
    type AS activity_type_code,
    assigned_to_user,
    deal_id,
    done::boolean AS is_done,
    due_to::timestamp AS due_timestamp,
    due_to::date AS due_date
FROM {{ source('postgres_public', 'activity') }}
WHERE activity_id IS NOT NULL
