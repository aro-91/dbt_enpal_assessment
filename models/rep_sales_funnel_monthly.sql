SELECT
    DATE(DATE_TRUNC('MONTH', stage_first_entered_timestamp)) AS month,
    stage_name AS kpi_name,
    stage_id AS funnel_step,
    CAST(COUNT(deal_id) AS INTEGER) AS deals_count
FROM {{ ref('fct_deal_stages_funnel') }}
LEFT JOIN {{ ref('dim_stages') }}
USING (stage_id)
GROUP BY 1, 2, 3