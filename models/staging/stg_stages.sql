{{
    config(
        materialized='view'
    )
}}

-- Staging model for stages with proper typing

SELECT
    stage_id::integer AS stage_id,
    stage_name,
    concat(
        'Step ', 
        stage_id::text, 
        ': ', 
        initcap(stage_name)
    ) AS funnel_step
FROM {{ source('postgres_public', 'stages') }}
WHERE stage_id IS NOT NULL
