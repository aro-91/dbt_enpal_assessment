SELECT
    CAST(id AS TEXT) AS user_id,
    CAST(name AS TEXT) AS user_name,
    CAST(email AS TEXT) AS user_email,
    CAST(modified AS TIMESTAMP) AS modified_at
FROM {{ source('pipedrive','users') }}