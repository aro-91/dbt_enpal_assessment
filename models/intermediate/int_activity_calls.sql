{{ config(materialized='view') }}

-- Activity-based funnel sub-steps (e.g., Sales Call 1 / 2)
SELECT
    pipedrive_activity.deal_id,
    date_trunc('month', pipedrive_activity.happened_at)::date AS month_start,
    map_activity.kpi_name,
    map_activity.funnel_step,
    map_activity.sort_order
FROM {{ ref('stg_pipedrive__activity') }} AS pipedrive_activity
INNER JOIN {{ ref('map_activity_to_funnel') }} AS map_activity
    ON pipedrive_activity.activity_type_key = map_activity.activity_type_key
WHERE coalesce(pipedrive_activity.is_done, true) = true
GROUP BY 1, 2, 3, 4, 5
