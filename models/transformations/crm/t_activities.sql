SELECT 
   a.activity_id
  ,ty.name AS activity_name
  ,a.assigned_to_user 
  ,a.deal_id 
  ,a.done AS is_done
  ,a.due_to
--  ,ty.active 
FROM {{ ref('sn_activities') }} a
  LEFT JOIN {{ ref('stg_activity_types') }} ty ON a.type = ty.type