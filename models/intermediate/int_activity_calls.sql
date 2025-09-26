{{ config(materialized='view') }}

with src as (
  select
    activity.activity_id,
    CASE WHEN  activity_types.name = 'Sales Call 1'
         THEN '2.1'
         WHEN  activity_types.name = 'Sales Call 2'
         THEN '3.1'
         END  as sales_stage_id,
    activity.deal_id::bigint,
    activity.due_at,
    activity_types.name
  from {{ ref('stg_pipedrive_activity') }} as activity
  inner join {{ ref('stg_pipedrive_activity_types') }} as activity_types
  on activity.type = activity_types.type
  where activity.done is true
  and activity_types.name in ('Sales Call 1', 'Sales Call 2')
)
select * from src