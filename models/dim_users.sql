SELECT
    id,
    name,
    email,
    modified AS last_modified_timestamp
FROM {{ ref('stg_users') }}