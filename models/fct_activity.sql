SELECT
    stg_activity.activity_id,
    dim_activity_types.id AS activity_type_id,
    stg_activity.assigned_to_user AS assigned_to_user_id,
    stg_activity.deal_id,
    stg_activity.done AS is_done,
    stg_activity.due_to AS due_to_timestamp
FROM {{ ref('stg_activity') }} AS stg_activity
LEFT JOIN {{ ref('dim_activity_types') }} AS dim_activity_types
ON stg_activity.type = dim_activity_types.key