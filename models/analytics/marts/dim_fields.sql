{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH fields AS (
  SELECT * FROM {{ ref('ag__fields') }}
),

final AS (
  SELECT
    unique_id,
    field_key,
    field_name,
    field_value_properties,
    option_id,
    label,
    MAX(_last_synced) AS _last_synced
  FROM fields
  GROUP BY 1, 2, 3, 4, 5, 6
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
