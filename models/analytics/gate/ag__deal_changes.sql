WITH deal_changes AS (
  SELECT * FROM {{ ref('stg__deal_changes') }}
),

final AS (
  SELECT
    unique_id,
    deal_id,
    TRIM(changed_field_key) AS change_field_name,
    new_value,
    change_time AS modified_at,
    _last_synced
  FROM deal_changes
)

SELECT * FROM final
