{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH source_with_field_values AS (
  SELECT
    id,
    field_key,
    name,
    field_value_options,
    {{ jsonb_extract_null_missing('field_value_options', 'id') }} AS option_id,
    {{ jsonb_extract_null_missing('field_value_options', 'label') }} AS label,
    _last_synced
  FROM {{ source('pipedrive_crm','src_fields') }}
  WHERE
    jsonb_array_length(field_value_options) > 0
  {% if is_incremental() %}

    AND _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

  {% endif %}
),

source_without_field_values AS (
  SELECT
    id,
    field_key,
    name,
    field_value_options,
    NULL AS option_id,
    NULL AS label,
    _last_synced
  FROM {{ source('pipedrive_crm','src_fields') }}
  WHERE
    jsonb_array_length(field_value_options) = 0
  {% if is_incremental() %}

    AND _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

  {% endif %}
),

final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['id', 'field_key', 'name', 'option_id','label']) }} AS unique_id,
    * 
  FROM 
  (
    SELECT
      id,
      field_key,
      name,
      field_value_options,
      option_id,
      label,
      _last_synced
    FROM source_with_field_values
    UNION ALL
    SELECT
      id,
      field_key,
      name,
      field_value_options,
      option_id,
      label,
      _last_synced
    FROM source_without_field_values
  )  
)

SELECT * FROM final
