WITH stages AS (
  SELECT * FROM {{ ref('stg__stages') }}
),

final AS (
  SELECT
    stage_id,
    TRIM(stage_name) AS stage_name,
    _last_synced
  FROM stages
  GROUP BY 1,2, 3
)

SELECT * FROM final
