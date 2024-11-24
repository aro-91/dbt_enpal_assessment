SELECT
   deal_id
  ,change_time
  ,new_value AS user_id
FROM {{ ref('stg_deal_changes') }} dc
WHERE changed_field_key = 'user_id'