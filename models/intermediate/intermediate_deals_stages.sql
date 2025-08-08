-- This intermediate model creates a single, unified timeline of events for each deal.
-- It combines stage changes and key activities to accurately track funnel progression.

WITH stage_events AS (
    -- Select the first time a deal enters a stage
    SELECT
        deal_id,
        new_value AS stage_id,
        DATE_TRUNC('month',MIN(change_time))::DATE AS month
    FROM {{ ref("stg_deal_changes") }}
    where changed_field_key = 'stage_id'
    GROUP BY 1, 2
),

activity_events AS (
    -- Select the first time a key activity is completed for a deal
    SELECT
        a.deal_id,
        at.activity_key as stage_id,
        DATE_TRUNC('month',MIN(a.due_time))::DATE AS month
    FROM {{ ref('stg_activity_types') }} AS at
    LEFT JOIN {{ ref('stg_activities') }} AS a
    ON a.activity_type = at.activity_key
    WHERE a.is_done = TRUE
        AND at.activity_key IN ('sc_2' , 'meeting')
    GROUP BY 1,2
),

all_events AS (
    -- Combine stage changes and activity events into a single list
    SELECT * FROM stage_events
    UNION ALL
    SELECT * FROM activity_events
)

-- Final model that orders events chronologically for each deal
SELECT
    ae.deal_id,
    sms.month,
    sms.kpi_name,
    sms.funnel_step
FROM
    {{ ref('stg_monthly_spine') }} sms
    LEFT JOIN all_events ae
ON sms.stage_id = ae.stage_id AND sms.month = ae.month
