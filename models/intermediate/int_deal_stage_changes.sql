{{
    config(
        materialized='incremental',
        unique_key='change_id',
        incremental_strategy='delete+insert'
    )
}}

-- Intermediate model: Extract all stage changes for each deal
-- This tracks when deals moved through each stage

WITH stage_changes AS (
    SELECT
        deal_id,
        change_time AS stage_entered_at,
        change_date AS stage_entered_date,
        DATE_TRUNC('month', change_time)::date AS stage_entered_month,
        new_value::numeric AS stage_id
    FROM {{ ref('stg_deal_changes') }}
    WHERE changed_field_key = 'stage_id'
        AND new_value IS NOT NULL
    {% if is_incremental() %}
        -- Incremental strategy: Only process new changes
        AND change_time > (SELECT MAX(stage_entered_at) FROM {{ this }})
    {% endif %}
),

-- Apply macro to filter out invalid date sequences (enforcing stage_id increases with time)
filtered_changes AS (
    {{ filter_increasing_stage_dates('stage_changes', 'deal_id', 'stage_id', 'stage_entered_at') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['sc.deal_id', 'sc.stage_id', 'sc.stage_entered_at']) }} as change_id,
    sc.deal_id,
    sc.stage_entered_at,
    sc.stage_entered_date,
    sc.stage_entered_month,
    sc.stage_id,
    s.stage_name,
    s.funnel_step
FROM filtered_changes sc
LEFT JOIN {{ ref('stg_stages') }} s
    ON sc.stage_id = s.stage_id
