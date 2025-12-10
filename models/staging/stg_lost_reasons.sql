{{
    config(
        materialized='view'
    )
}}

-- Staging model for lost reasons from fields source table

select
    -- Unnest the JSONB array into new rows
    unnested_value ->> 'id' AS lost_value_id,
    unnested_value ->> 'label' AS lost_value_label,
    id AS field_row_id
FROM 
    fields t,
    LATERAL jsonb_array_elements(t.field_value_options::jsonb) AS unnested_value
WHERE
    -- Only process rows that contain the array we are interested in
    t.field_key IN ('lost_reason') -- ('stage_id', 'lost_reason')
    AND t.field_value_options IS NOT null