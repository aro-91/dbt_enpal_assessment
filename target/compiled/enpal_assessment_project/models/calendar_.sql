WITH generate_series AS (
SELECT 
   DATE(GENERATE_SERIES(DATE('2023-01-01'), DATE('2030-12-31'), '1 day')) AS day
)
SELECT 
   day
  ,DATE(DATE_TRUNC('month', day)) AS month
FROM generate_series