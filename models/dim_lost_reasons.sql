SELECT
    options.id,
    options.label,
    stg_fields.id AS field_id
FROM 
    {{ ref('stg_fields') }} AS stg_fields, 
    JSONB_TO_RECORDSET(stg_fields.field_value_options) AS options(id integer, label varchar)
WHERE
    stg_fields.field_key = 'lost_reason'