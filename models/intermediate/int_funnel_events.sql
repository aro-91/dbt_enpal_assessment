{{ config(materialized='view') }}

with activity_calls as (
  select
    activity_calls.due_at         as funnel_event_at,
    activity_calls.name           as funnel_event_name,
    activity_calls.sales_stage_id as funnel_event_step,
    activity_calls.deal_id        as funnel_event_id
    
  from {{ ref('int_activity_calls') }} as activity_calls
)
    ,deal_stage_changes as (
        select 
            deal_stage_changes.changed_at          as funnel_event_at,
            deal_stage_changes.stage_name          as funnel_event_name,
            deal_stage_changes.stage_id::VARCHAR   as funnel_event_step,
            deal_stage_changes.deal_id             as funnel_event_id

        from  {{ ref('int_deal_stage_changes') }} as deal_stage_changes
    )
    ,src as (
        select * from activity_calls
        union all 
        select * from deal_stage_changes
    )
    select * from src