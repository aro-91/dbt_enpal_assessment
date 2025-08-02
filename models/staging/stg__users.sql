{{
  config(unique_key="id", 
  sort=["_last_synced"]) 
}}

WITH source AS (
  SELECT * FROM {{ source('pipedrive_crm', 'src_users') }}
  {% if is_incremental() %}

    WHERE _last_synced >= (SELECT MAX(_last_synced) FROM {{ this }} )

  {% endif %}
)

SELECT * FROM source
