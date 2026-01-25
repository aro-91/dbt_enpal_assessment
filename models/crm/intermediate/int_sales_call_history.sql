select
    distinct deal_stages.deal_id,
    date_trunc('month', stage_start_time)::date AS month_changed, -- this will bring the first day of the month, can be changed the month name etc
    activity_types.activity_type_name,
    CASE
        WHEN activity_types.activity_type_name='Sales Call 1' THEN '2.1'
        WHEN activity_types.activity_type_name='Sales Call 2' THEN '3.1'
        ELSE 'unknown'
    END AS funnel_step
FROM {{ ref('int_deal_stages_history') }} AS deal_stages
JOIN {{ ref('int_activity_history') }} AS activity_history
    ON activity_history.deal_id = deal_stages.deal_id
JOIN {{ ref('stg_activity_types') }} AS activity_types
    ON activity_types.activity_type_category = activity_history.activity_type_category
WHERE deal_stages.stage_id IN ('2','3')
    and activity_types.activity_type_category IN ('meeting', 'sc_2')
    and deal_stages.is_lost_deal = false