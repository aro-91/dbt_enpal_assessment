SELECT
    CAST(id AS TEXT) AS activity_type_id,
    CAST(name AS TEXT) AS activity_type_name,
    CAST(type AS TEXT) AS activity_type_group,
    CASE
      WHEN LOWER(active) = 'yes' THEN TRUE
      WHEN LOWER(active) = 'no'  THEN FALSE
        ELSE NULL END
     AS is_active -- convert booalen for simplicity
FROM {{ source('pipedrive','activity_types') }}