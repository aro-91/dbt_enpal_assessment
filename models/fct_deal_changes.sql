SELECT
    stg_deal_changes.deal_id,
    change_time AS change_timestamp,
    dim_fields.id AS changed_field_id,
    stg_deal_changes.new_value
FROM {{ ref('stg_deal_changes') }} AS stg_deal_changes
LEFT JOIN {{ ref('dim_fields') }} AS dim_fields
    ON stg_deal_changes.changed_field_key = dim_fields.key