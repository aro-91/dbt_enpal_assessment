SELECT
    DATE(DATE_TRUNC('MONTH', dw_deal_stages_funnel.stage_first_entered_timestamp)) AS month,
    dim_stages.label AS kpi_name,
    CAST(dim_stages.id AS VARCHAR) AS funnel_step,
    CAST(COUNT(dw_deal_stages_funnel.deal_id) AS INTEGER) AS deals_count
FROM
    {{ ref('dw_deal_stages_funnel') }} AS dw_deal_stages_funnel
LEFT JOIN 
    {{ ref('dim_stages') }} AS dim_stages
    ON dw_deal_stages_funnel.stage_id = dim_stages.id
GROUP BY
    1, 2, 3

UNION ALL

SELECT
    DATE(DATE_TRUNC('MONTH', dw_deal_activities_funnel.activity_type_first_done_timestamp)) AS month,
    dim_activity_types.label AS kpi_name,
    CASE dim_activity_types.label
        WHEN 'Sales Call 1' THEN '2.1'
        WHEN 'Sales Call 2' THEN '3.1'
    END AS funnel_step,
    CAST(COUNT(dw_deal_activities_funnel.deal_id) AS INTEGER) AS deals_count
FROM
    {{ ref('dw_deal_activities_funnel') }} AS dw_deal_activities_funnel
LEFT JOIN 
    {{ ref('dim_activity_types') }} AS dim_activity_types
    ON dw_deal_activities_funnel.activity_type_id = dim_activity_types.id
WHERE
    dim_activity_types.label IN ('Sales Call 1', 'Sales Call 2')
GROUP BY
    1, 2, 3

ORDER BY
    1, 3