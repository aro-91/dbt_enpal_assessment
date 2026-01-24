SELECT
    -- Create an unique primary key for any deal_changes
    MD5(CONCAT(deal_id, changed_field_key, CAST(change_time AS TEXT))) AS change_id,
    CAST(deal_id AS TEXT) AS deal_id
    CAST(changed_field_key AS TEXT) AS changed_field_key
    CAST(new_value AS TEXT) AS new_value
    CAST(change_time AS TIMESTAMP) AS changed_at
FROM {{ source('pipedrive','deal_changes') }}