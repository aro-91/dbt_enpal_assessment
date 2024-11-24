SELECT
   id
  ,name
  ,CASE WHEN active = 'Yes' THEN TRUE ELSE FALSE END AS active
  ,type
FROM "postgres"."public"."activity_types"