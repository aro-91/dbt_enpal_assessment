SELECT
    deal_id,
    CAST(new_value AS INTEGER) AS stage_id,
    change_time AS stage_entered_timestamp
FROM {{ ref('stg_deal_changes') }}
WHERE changed_field_key = 'stage_id'