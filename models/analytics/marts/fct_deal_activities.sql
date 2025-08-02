{{
  config(unique_key="unique_id", 
  sort=["max_updated_at"]) 
}}

WITH activities AS (
  SELECT * FROM {{ ref('dim_activities') }}
),

activity_types AS (
  SELECT * FROM {{ ref('dim_activity_types') }}
),

final AS (
  SELECT
    activities.unique_id,
    activities.deal_id,
    activities.activity_id,
    -- activity details
    activity_types.activity_name,
    activities.activity_type,
    activity_types.is_active AS is_active_activity,
    -- activity metadata
    activities.is_completed,
    activities.due_at, 
    activities.assigned_user_id,
    -- updated at
    GREATEST(
      activities._last_synced,
      activity_types._last_synced
    ) AS max_updated_at
  FROM activities
  LEFT JOIN activity_types
    ON
      activities.activity_type = activity_types.activity_type
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE max_updated_at >= (SELECT MAX(max_updated_at) FROM {{ this }} )

{% endif %}
