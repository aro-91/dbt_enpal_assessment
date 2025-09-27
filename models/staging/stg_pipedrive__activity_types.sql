{{ config(materialized='view') }}

WITH src AS (
    SELECT
        id::bigint AS activity_type_id,
        type AS activity_type_key,
        name AS activity_type_name,
        -- boolean normalization
        coalesce(
            lower(coalesce(active::text, '')) IN ('yes', 'true', 't', '1'),
            false
        ) AS is_active
    FROM {{ source('pipedrive','activity_types') }}
)

SELECT activity_type_id,
       activity_type_key,
       activity_type_name,
       is_active 
FROM src
