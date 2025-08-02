WITH activity_types AS (
  SELECT * FROM {{ ref('stg__activity_types') }}
),

final AS (
  SELECT
    id AS activity_type_id,
    TRIM(name) AS activity_name,
    TRIM(type) AS activity_type,
    COALESCE(active = 'Yes' , False) AS is_active,
    _last_synced
  FROM activity_types 
)

SELECT * FROM final
