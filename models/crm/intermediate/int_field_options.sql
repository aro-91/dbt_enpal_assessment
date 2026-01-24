SELECT
    field_id,
    field_key,
    elem ->> 'id' as label_id,
    elem ->> 'label' as label_value
FROM {{ ref('stg_pipedrive_fields') }} ,
LATERAL jsonb_array_elements(field_value_options::jsonb) AS 
WHERE
    field_value_options IS NOT NULL
    AND field_value_options <> ''