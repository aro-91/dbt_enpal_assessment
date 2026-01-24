SELECT
    CAST(activity_id AS TEXT) AS activity_id,
    CAST(assigned_to_user AS TEXT) AS assigned_user_id,
    CAST(deal_id AS TEXT) AS deal_id,
    CAST(done AS BOOLEAN) AS is_done,
    CAST(due_to AS TIMESTAMP) AS due_to_at,
    CAST(type AS TEXT) AS activity_type
FROM {{ source('pipedrive','activity') }}