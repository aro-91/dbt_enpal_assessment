SELECT
    HASHTEXT(deal_id || '_' || new_value) AS id,
    deal_id,
    CAST(new_value AS INTEGER) AS stage_id,
    MIN(change_time) AS stage_first_entered_timestamp
FROM {{ ref('stg_deal_changes') }}
WHERE changed_field_key = 'stage_id'
GROUP BY 1, 2, 3