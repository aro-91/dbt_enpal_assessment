{{
    config(
        materialized='view'
    )
}}

-- Staging model for deal changes with data type conversions and basic cleaning

SELECT
    deal_id,
    change_time::timestamp AS change_time,
    changed_field_key,
    new_value,
    -- Extract the date for easier filtering
    change_time::date AS change_date
FROM {{ source('postgres_public', 'deal_changes') }}
WHERE deal_id IS NOT NULL
    AND change_time IS NOT NULL
