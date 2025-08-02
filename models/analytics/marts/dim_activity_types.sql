{{
  config(unique_key="activity_type_id", 
  sort=["_last_synced"]) 
}}

WITH activity_types AS (
  SELECT * FROM {{ ref('ag__activity_types') }}
),

final AS (
  SELECT
    activity_type_id,
    activity_name,
    activity_type,
    is_active,
    MAX(_last_synced) AS _last_synced
  FROM activity_types
  GROUP BY 1, 2, 3, 4
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
