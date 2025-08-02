{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH deal_changes AS (
  SELECT * FROM {{ ref('ag__deal_changes') }}
),

final AS (
  SELECT
    unique_id,
    deal_id,
    change_field_name,
    new_value,
    modified_at,
    MAX(_last_synced) AS _last_synced
  FROM deal_changes
  GROUP BY 1, 2, 3, 4, 5
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
