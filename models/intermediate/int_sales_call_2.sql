{{
    config(
        materialized='table'
    )
}}

-- Intermediate model: Extract Sales Call 2 activities (Step 3.1)
-- These are sc_2 type activities

WITH sales_call_2 AS (
    SELECT
        a.deal_id,
        MIN(a.due_timestamp) AS first_sc2_date,
        DATE_TRUNC('month', MIN(a.due_timestamp))::date AS first_sc2_month,
        at.activity_name AS stage_name,
        concat(
            'Step 3.1: ', 
            at.activity_name
        ) AS funnel_step,
        3.1 AS stage_id,
        COUNT(*) AS sc2_count
    FROM {{ ref('stg_activity') }} a
    INNER JOIN {{ ref('stg_activity_types') }} at
        ON a.activity_type_code = at.activity_type_code
    WHERE at.activity_name = 'Sales Call 2'
        AND a.deal_id IS NOT NULL
    GROUP BY a.deal_id, at.activity_name
)

SELECT * FROM sales_call_2
