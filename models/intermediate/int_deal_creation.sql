{{
    config(
        materialized='incremental',
        unique_key='deal_id'
    )
}}

-- Intermediate model: Extract deal creation information
-- This gives us when each deal was created (add_time field)

WITH deal_creation AS (
    SELECT
        deal_id,
        MIN(change_time) AS created_at,
        MIN(change_date) AS created_date,
        DATE_TRUNC('month', MIN(change_time))::date AS created_month
    FROM {{ ref('stg_deal_changes') }}
    WHERE changed_field_key = 'add_time'
    {% if is_incremental() %}
        -- Incremental strategy: Only process new deals created after the last run
        AND change_time > (SELECT MAX(created_at) FROM {{ this }})
    {% endif %}
    GROUP BY deal_id
)

SELECT * FROM deal_creation
