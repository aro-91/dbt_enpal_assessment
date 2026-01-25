SELECT
    field_id,
    field_key,
    (elem ->> 'id')::int as label_id,
    elem ->> 'label' as label_value
FROM {{ ref('stg_fields') }} ,
LATERAL jsonb_array_elements(field_value_options::jsonb) AS elem
WHERE
    field_value_options IS NOT NULL
    AND field_value_options <> ''