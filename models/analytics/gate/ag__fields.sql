WITH fields AS (
  SELECT * FROM {{ ref('stg__fields') }}
),

final AS (
  SELECT
    unique_id,
    field_key,
    TRIM("name") AS field_name,
    field_value_options AS field_value_properties,
    COALESCE(option_id, NULL) AS option_id,
    COALESCE(label, NULL) AS label,
    _last_synced
  FROM fields
  GROUP BY 1, 2, 3, 4, 5, 6, 7
)

SELECT * FROM final
