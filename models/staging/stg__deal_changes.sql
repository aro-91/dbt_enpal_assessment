{{
  config(unique_key="unique_id", 
  sort=["_last_synced"]) 
}}

WITH source AS (
  SELECT 
    {{ dbt_utils.generate_surrogate_key(['deal_id', 'change_time', 'changed_field_key']) }} AS unique_id,
    * 
  FROM {{ source('pipedrive_crm', 'src_deal_changes') }}
  {% if is_incremental() %}

    WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

  {% endif %}
)

SELECT * FROM source
