SELECT
    id,
    field_key AS key,
    name
FROM {{ ref('stg_fields') }}