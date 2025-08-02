{{
  config(unique_key="user_id", 
  sort=["_last_synced"]) 
}}

WITH users AS (
  SELECT * FROM {{ ref('ag__users') }}
),

final AS (
  SELECT
    user_id,
    user_name,
    email,
    modified_at,
    MAX(_last_synced) AS _last_synced
  FROM users
  GROUP BY 1, 2, 3, 4
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

{% endif %}
