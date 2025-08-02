{{
  config(unique_key="unique_id", 
  sort=["max_updated_at"]) 
}}

WITH deal_stages AS (
  SELECT
    unique_id,
    deal_id,
    new_value::INTEGER AS stage_id,
    modified_at,
    MAX(_last_synced) AS _last_synced
  FROM {{ ref('dim_deal_changes') }}
  WHERE
    change_field_name = 'stage_id'
  GROUP BY 1, 2, 3, 4
),

stage_details AS (
  SELECT
    stage_id,
    stage_name,
    MAX(_last_synced) AS _last_synced
  FROM {{ ref('dim_stages') }}
  GROUP BY 1, 2
),

final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['deal_stages.deal_id', 'deal_stages.stage_id', 'deal_stages.modified_at']) }} AS unique_id,
    deal_stages.deal_id,
    deal_stages.modified_at,
    -- stage details
    deal_stages.stage_id,
    stage_details.stage_name,
    GREATEST(
      deal_stages._last_synced,
      stage_details._last_synced
    ) AS max_updated_at
  FROM deal_stages
  LEFT JOIN stage_details
    ON
      deal_stages.stage_id = stage_details.stage_id
)

SELECT * FROM final
{% if is_incremental() %}

  WHERE max_updated_at >= (SELECT MAX(max_updated_at) FROM {{ this }} )

{% endif %}
