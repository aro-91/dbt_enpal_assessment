{{ config(materialized='view') }}

WITH deal_changes_source AS (
    SELECT
        deal_changes.deal_id::bigint         AS deal_id,
        deal_changes.changed_field_key::text AS changed_field_key,
        deal_changes.new_value::text         AS new_value,
        deal_changes.change_time::timestamp  AS changed_at
    FROM {{ source('pipedrive', 'deal_changes') }} AS deal_changes
),

typed_stage_changes AS (
    -- Keep raw text "new_value" (auditable).
    -- Add a SAFE typed "new_stage_id" for joins.
    SELECT
        src.deal_id,
        src.changed_field_key,
        src.new_value,
        src.changed_at,
        CASE
            WHEN src.changed_field_key = 'stage_id'
            AND src.new_value ~ '^\d+$'
            THEN src.new_value::bigint
        END AS new_stage_id
    FROM deal_changes_source AS src
)

SELECT
    tsc.deal_id,
    tsc.changed_field_key,
    tsc.new_value,
    tsc.changed_at,
    tsc.new_stage_id
FROM typed_stage_changes AS tsc