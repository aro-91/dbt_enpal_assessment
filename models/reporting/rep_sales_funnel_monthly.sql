{{
    config(
        materialized='table',
        post_hook=[
            "{{ generate_index(this, 'month') }}",
            "{{ generate_index(this, 'kpi_name') }}"
        ]
    )
}}

/*
    Sales Funnel Monthly Report
    
    This model generates monthly KPI metrics for each step of the sales funnel.
    
    Funnel Steps:
    - Step 1: Lead Generation (when deal is created)
    - Step 2: Qualified Lead (when deal reaches stage 2)
    - Step 2.1: Sales Call 1 (when first meeting activity occurs)
    - Step 3: Needs Assessment (when deal reaches stage 3)
    - Step 3.1: Sales Call 2 (when first SC2 activity occurs)
    - Step 4: Proposal/Quote Preparation (when deal reaches stage 4)
    - Step 5: Negotiation (when deal reaches stage 5)
    - Step 6: Closing (when deal reaches stage 6)
    - Step 7: Implementation/Onboarding (when deal reaches stage 7)
    - Step 8: Follow-up/Customer Success (when deal reaches stage 8)
    - Step 9: Renewal/Expansion (when deal reaches stage 9)
*/

WITH 

-- Get all deals created by month
deals_created AS (
    SELECT
        created_month AS month,
        'Lead Generation' AS kpi_name,
        'Step 1: Lead Generation' AS funnel_step,
        1 AS stage_id,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ ref('int_deal_creation') }}
    GROUP BY created_month
),

-- Stage-based KPIs (Steps 2-9, excluding 2.1 and 3.1)
stage_progression AS (
    SELECT
        stage_entered_month AS month,
        stage_name AS kpi_name,
        funnel_step,
        stage_id,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ ref('int_deal_stage_changes') }}
    WHERE stage_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9)
    GROUP BY stage_entered_month, stage_name, funnel_step, stage_id
),

-- Sales Call 1 activity KPI (Step 2.1)
sales_call_1_kpi AS (
    SELECT
        first_sc1_month AS month,
        stage_name AS kpi_name,
        funnel_step,
        stage_id,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ ref('int_sales_call_1') }}
    GROUP BY first_sc1_month, stage_name, funnel_step, stage_id
),

-- Sales Call 2 activity KPI (Step 3.1)
sales_call_2_kpi AS (
    SELECT
        first_sc2_month AS month,
        stage_name AS kpi_name,
        funnel_step,
        stage_id,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ ref('int_sales_call_2') }}
    GROUP BY first_sc2_month, stage_name, funnel_step, stage_id
),

-- Union all KPIs together
all_kpis AS (
    -- SELECT * FROM deals_created
    -- UNION ALL
    SELECT * FROM stage_progression
    UNION ALL
    SELECT * FROM sales_call_1_kpi
    UNION ALL
    SELECT * FROM sales_call_2_kpi
)

-- Final output with proper ordering
SELECT
    month,
    kpi_name,
    funnel_step,
    deals_count
FROM all_kpis
WHERE month IS NOT NULL
ORDER BY month, stage_id asc
