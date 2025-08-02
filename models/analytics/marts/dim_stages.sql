{{
  config(unique_key="stage_id", 
  sort=["_last_synced"]) 
}}

WITH stages AS (
  SELECT * FROM {{ ref('ag__stages') }}
),

final AS (
  SELECT
    stage_id,
    stage_name,
    MAX(_last_synced) AS _last_synced
  FROM stages
  GROUP BY 1, 2
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
