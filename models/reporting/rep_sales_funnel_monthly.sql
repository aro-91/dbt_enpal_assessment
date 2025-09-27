{{ config(
    materialized='table',
    tags=['reporting','rep_sales_funnel_monthly']
) }}

{# Seeds to union for step definitions #}
{% set step_maps = ['map_stage_to_funnel', 'map_activity_to_funnel'] %}

-- Collect all funnel steps from both mappings, keep one label + a stable order
WITH steps_raw AS (
    {% for m in step_maps %}
    SELECT
        funnel_step,
        kpi_name,
        sort_order
    FROM {{ ref(m) }}
    {% if not loop.last %}UNION
    {% endif %}
    {% endfor %}
),

steps_dim AS (
    SELECT
        funnel_step,
        MAX(kpi_name)    AS kpi_name,
        MIN(sort_order)  AS sort_order
    FROM steps_raw
    GROUP BY funnel_step
),

-- Month spine (inclusive) from earliest event to current month
months_spine AS (
    SELECT month FROM {{ ref('int_calendar_months') }}
),

-- Stage + activity events aggregated per month × funnel_step
event_counts AS (
    SELECT
        month,
        funnel_step,
        COUNT(DISTINCT deal_id)::BIGINT AS deals_count
    FROM {{ ref('int_funnel_events') }}
    GROUP BY 1, 2
)

-- Final: full grid of months × steps with zero-fill
SELECT
    months.month,
    steps.kpi_name,
    steps.funnel_step,
    COALESCE(counts.deals_count, 0) AS deals_count
FROM months_spine AS months
CROSS JOIN steps_dim AS steps
LEFT OUTER JOIN event_counts AS counts
    ON months.month = counts.month
   AND steps.funnel_step = counts.funnel_step
ORDER BY months.month, steps.sort_order