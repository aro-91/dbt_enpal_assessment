SELECT
    HASHTEXT(deal_id || '_' || new_value) AS deal_stage_id,
    deal_id,
    CAST(new_value AS INTEGER) AS stage_id,
    MIN(change_timestamp) AS stage_first_entered_timestamp
FROM {{ ref('fct_deal_changes') }} AS fct_deal_changes
LEFT JOIN {{ ref('dim_fields') }} AS dim_fields
    ON fct_deal_changes.changed_field_id = dim_fields.id
WHERE dim_fields.key = 'stage_id'
GROUP BY 1, 2, 3