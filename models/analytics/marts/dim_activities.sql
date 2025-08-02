{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH activities AS (
  SELECT * FROM {{ ref('ag__activities') }}
),

final AS (
  SELECT
    unique_id,
    activity_id,
    activity_type,
    is_completed,
    due_at, 
    assigned_user_id,
    deal_id,
    MAX(_last_synced) AS _last_synced
  FROM activities
  GROUP BY 1, 2, 3, 4, 5, 6, 7
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
