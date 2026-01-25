select
    DATE_TRUNC('month', stage_start_time)::date AS month_reported,
    stage_name AS kpi_name,
    stage_id::text AS funnel_step,
    COUNT(distinct deal_id) AS deals_count
from {{ ref('int_deal_stages_history') }}
where is_lost_deal = false
group by 
    month_reported,
    kpi_name,
    funnel_step

UNION ALL

SELECT
    month_changed AS month_reported,
    activity_type_name AS kpi_name,
    funnel_step AS funnel_step,
    COUNT(DISTINCT deal_id) AS deals_count
FROM {{ ref('int_sales_call_history') }}
GROUP BY 
    month_reported,
    kpi_name,
    funnel_step
