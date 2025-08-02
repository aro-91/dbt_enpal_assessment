WITH activities AS (
  SELECT * FROM {{ ref('stg__activities') }}
),

final AS (
  SELECT
    unique_id,
    activity_id,
    TRIM("type") AS activity_type,
    done AS is_completed,
    due_to AS due_at, 
    assigned_to_user AS assigned_user_id,
    deal_id,
    _last_synced
  FROM activities
)

SELECT * FROM final
