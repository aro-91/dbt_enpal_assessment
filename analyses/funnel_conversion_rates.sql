-- Calculate conversion rates between funnel steps
WITH funnel_data AS (
    SELECT 
        month,
        funnel_step,
        deals_count
    FROM {{ ref('rep_sales_funnel_monthly') }}
),

pivoted AS (
    SELECT
        month,
        MAX(CASE WHEN funnel_step = 'Step 1: Lead Generation' THEN deals_count ELSE 0 END) as step_1_count,
        MAX(CASE WHEN funnel_step = 'Step 2: Qualified Lead' THEN deals_count ELSE 0 END) as step_2_count,
        MAX(CASE WHEN funnel_step = 'Step 6: Closing' THEN deals_count ELSE 0 END) as step_6_count
    FROM funnel_data
    GROUP BY month
)

SELECT
    month,
    step_1_count,
    step_2_count,
    step_6_count,
    CASE WHEN step_1_count > 0 THEN ROUND(step_2_count::numeric / step_1_count * 100, 2) ELSE 0 END as lead_to_qualified_conversion,
    CASE WHEN step_2_count > 0 THEN ROUND(step_6_count::numeric / step_2_count * 100, 2) ELSE 0 END as qualified_to_close_conversion,
    CASE WHEN step_1_count > 0 THEN ROUND(step_6_count::numeric / step_1_count * 100, 2) ELSE 0 END as total_conversion_rate
FROM pivoted
ORDER BY month DESC
