SELECT
    CAST(stage_id AS TEXT) AS stage_id,
    CAST(stage_name AS TEXT) AS stage_name
FROM {{ source('pipedrive','stages') }}