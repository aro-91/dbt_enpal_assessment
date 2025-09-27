{{ config(materialized='view') }}

-- Derive stages from the `fields` seed (metadata for the `stage_id` picklist).

WITH fields_meta AS (
    SELECT
        f.id::int                AS field_id,
        f.field_key::text        AS field_key,
        COALESCE(NULLIF(f.field_value_options, ''), '[]')::jsonb
                                 AS option_list
    FROM {{ source('pipedrive', 'fields') }} AS f
    WHERE f.field_key = 'stage_id'
),

exploded AS (
    SELECT
        (o.elem ->> 'id')::int   AS stage_id,
        TRIM(o.elem ->> 'label') AS stage_name
    FROM fields_meta AS fm
    CROSS JOIN LATERAL
        jsonb_array_elements(fm.option_list) AS o(elem)
)

SELECT
    e.stage_id,
    e.stage_name
FROM exploded AS e
ORDER BY e.stage_id

