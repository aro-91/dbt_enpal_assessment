{{ config(materialized='table') }}

-- Extract all stage changes for deals
WITH stage_changes AS (
    SELECT
        deal_id,
        change_time,
        CAST(new_value AS INTEGER) AS stage_id
    FROM {{ source('postgres_public', 'deal_changes') }}
    WHERE changed_field_key = 'stage_id'
),

-- Aggregate stage changes by month
monthly_stage_funnel AS (
    SELECT
        DATE_TRUNC('month', sc.change_time)::DATE AS month,
        s.stage_name AS kpi_name,
        s.stage_id::NUMERIC AS funnel_step,
        COUNT(DISTINCT sc.deal_id) AS deals_count
    FROM stage_changes sc
    INNER JOIN {{ source('postgres_public', 'stages') }} s
        ON sc.stage_id = s.stage_id
    GROUP BY 1, 2, 3
),

-- Extract Sales Call 1 activities (sub-step 2.1)
sales_call_1 AS (
    SELECT
        DATE_TRUNC('month', due_to)::DATE AS month,
        'Sales Call 1' AS kpi_name,
        2.1::NUMERIC AS funnel_step,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ source('postgres_public', 'activity') }}
    WHERE type = 'meeting' AND deal_id IS NOT NULL
    GROUP BY 1
),

-- Extract Sales Call 2 activities (sub-step 3.1)
sales_call_2 AS (
    SELECT
        DATE_TRUNC('month', due_to)::DATE AS month,
        'Sales Call 2' AS kpi_name,
        3.1::NUMERIC AS funnel_step,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ source('postgres_public', 'activity') }}
    WHERE type = 'sc_2' AND deal_id IS NOT NULL
    GROUP BY 1
)

-- Combine all funnel metrics
SELECT
    month,
    kpi_name,
    funnel_step,
    deals_count
FROM monthly_stage_funnel

UNION ALL

SELECT
    month,
    kpi_name,
    funnel_step,
    deals_count
FROM sales_call_1

UNION ALL

SELECT
    month,
    kpi_name,
    funnel_step,
    deals_count
FROM sales_call_2

ORDER BY month, funnel_step