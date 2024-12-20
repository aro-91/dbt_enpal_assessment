SELECT
    deal_id,
    new_value AS stage_id,
    change_time AS stage_entered_timestamp
FROM {{ ref('deal_changes') }}
WHERE changed_field_key = 'stage_id'
QUALIFY change_time = MIN(change_time) OVER (PARTITION BY deal_id, new_value)