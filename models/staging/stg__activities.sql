{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH source AS (
  SELECT 
    {{ dbt_utils.generate_surrogate_key(['activity_id', 'deal_id']) }} AS unique_id,
    * 
  FROM {{ source('pipedrive_crm', 'src_activity') }}
  {% if is_incremental() %}

    WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

  {% endif %}
)

SELECT * FROM source
