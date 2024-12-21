SELECT
    id,
    name AS label,
    CASE
        WHEN active = 'Yes' THEN TRUE
        WHEN active = 'No' THEN FALSE
    END AS is_active,
    type AS key
FROM {{ ref('stg_activity_types') }}