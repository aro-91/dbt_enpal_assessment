WITH deals AS (
    -- loading data to use
SELECT *
FROM "postgres"."public_staging"."stg_deal_changes"
)

, deal_creation AS (
    -- date of the deal creation
SELECT
   deal_id
  ,change_time
  ,changed_field_key
  ,TO_TIMESTAMP(REPLACE(new_value, 'T', ' '), 'YYYY-MM-DD HH24:MI:SS') AS new_value
FROM deals d
WHERE changed_field_key = 'add_time'
)

, activities_substeps AS (
    -- getting the Sales calls from the activities table
    -- should only 'is_done' be considered...?
SELECT
   deal_id
  ,due_to AS change_time
  ,CASE
     WHEN activity_name = 'Sales Call 1' THEN 2.1
   	 WHEN activity_name = 'Sales Call 2' THEN 3.1
   END stage_id
  ,activity_name AS stage_name
FROM "postgres"."public_crm"."t_activities"
WHERE activity_name IN ('Sales Call 1', 'Sales Call 2')
--  AND is_done IS TRUE
)

, stage_events AS (
SELECT
   d.deal_id 
  ,d.change_time
  ,d.new_value::FLOAT AS stage_id
  ,s.stage_name
FROM deals d
 LEFT JOIN "postgres"."public_staging"."stg_stages" s ON d.new_value::NUMERIC = s.stage_id::NUMERIC
WHERE changed_field_key = 'stage_id'
)

SELECT
   deal_id
  ,new_value AS change_time -- adding the official deal creation date, although they seem to be always the same
  ,0.0 AS stage_id
  ,'Deal creation' AS stage_name
FROM deal_creation 
UNION ALL
SELECT 
   deal_id
  ,change_time
  ,stage_id
  ,stage_name
FROM stage_events
UNION ALL
-- adding only activities that exist in deal_changes
SELECT
   deal_id
  ,change_time
  ,stage_id::FLOAT
  ,stage_name
FROM activities_substeps
WHERE deal_id IN (SELECT DISTINCT deal_id FROM stage_events)