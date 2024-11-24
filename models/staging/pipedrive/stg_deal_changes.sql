SELECT
   deal_id
  ,change_time
  ,changed_field_key
  ,new_value
FROM {{ source('postgres_public','deal_changes') }}

{%if is_incremental() %}
  WHERE change_time > (SELECT MAX(change_time) FROM {{ this }})
{% endif %}