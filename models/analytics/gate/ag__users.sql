WITH users AS (
  SELECT * FROM {{ ref('stg__users') }}
),

final AS (
  SELECT
    id AS user_id,
    {{ mask_field('TRIM(name)') }} AS user_name,
    {{ mask_field('TRIM(email)') }} AS email,
    modified AS modified_at,
    _last_synced
  FROM users
  GROUP BY 1, 2, 3, 4, 5
)

SELECT * FROM final