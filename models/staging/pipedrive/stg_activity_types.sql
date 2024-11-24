SELECT
   id
  ,name
  ,CASE WHEN active = 'Yes' THEN TRUE ELSE FALSE END AS active
  ,type
FROM {{ source('postgres_public','activity_types') }}