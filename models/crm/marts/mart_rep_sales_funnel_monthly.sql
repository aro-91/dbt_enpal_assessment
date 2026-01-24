SELECT
    DATE_TRUNC('month', stage_started_at) AS month_reported,
    unpivot_fields.option_label AS kpi_name,
    unpivot_fields.option_id AS funnel_step,
    COUNT(DISTINCT deal_changes.deal_id) AS deals_count
FROM {{ ref('int_deal_stages_history') }} AS deal_changes
LEFT JOIN {{ ref('int_field_options') }} AS unpivot_fields
    ON unpivot_fields.field_key = deal_changes.changed_field_key
        AND unpivot_fields.option_id = deal_changes.stage
GROUP BY month_reported, kpi_name, funnel_step

UNION ALL

SELECT
    month_changed AS month_reported,
    activity_type_name AS kpi_name,
    funnel_step AS funnel_step,
    COUNT(DISTINCT deal_id) AS deals_count

FROM {{ ref('int_sales_call_funnel') }}
GROUP BY month_reported, kpi_name, funnel_step
