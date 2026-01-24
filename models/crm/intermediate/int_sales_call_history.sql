SELECT
    DISTINCT deals.deal_id
    , date_trunc('month', stage_started_at) AS month_changed
    , act_types.activity_type_name
    , CASE
        WHEN act_types.activity_type_name='Sales Call 1' THEN '2.1'
        WHEN act_types.activity_type_name='Sales Call 2' THEN '3.1'
        ELSE 'UNKNOWN'
    END AS funnel_step
FROM {{ ref('int_deal_stages_history') }} AS deals
JOIN {{ ref('int_activity_history') }} AS act
    ON act.deal_id=deals.deal_id
    --       AND deals.stage_started_at<due_to_at -- Needs confirmation. I believe that it is needed but just for the shake of having 2 activities
JOIN {{ ref('stg_activity_types') }} AS act_types
    ON act_types.activity_type_group = act.activity_type
WHERE deals.stage IN ('2','3')
    AND activity_type_group IN ('meeting', 'sc_2')
    AND is_done = TRUE -- Needs confirmation if it is needed but I assume that only activities that actually happened are needed