{{ config(materialized='view') }}

WITH src AS (
    SELECT
        stage_id::bigint AS stage_id,
        stage_name
    FROM {{ source('pipedrive','stages') }}
)

SELECT
    stage_id,
    stage_name
FROM src
