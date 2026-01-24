SELECT
    CAST(id AS TEXT) AS field_id,
    CAST(field_key AS TEXT) AS field_key,
    CAST(name AS TEXT) AS field_name,
    CAST(field_value_options AS TEXT) AS field_value_options
FROM {{ source('pipedrive','fields') }}