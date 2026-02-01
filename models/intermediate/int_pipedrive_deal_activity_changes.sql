with activities as (
  select
    deal_id,
    stg_pipedrive_activity_types.activity_type_name,
    is_done,
    due_to_at
  from {{ ref('stg_pipedrive_activity') }} as stg_pipedrive_activity
  left join {{ ref('stg_pipedrive_activity_types') }} as stg_pipedrive_activity_types on stg_pipedrive_activity_types.activity_type = stg_pipedrive_activity.task_type
  where is_done = true
    and activity_type_name in ('Sales Call 1', 'Sales Call 2')
),
stage_activities as (
    select
        int_pipedrive_deal_stage_changes.deal_id,
        int_pipedrive_deal_stage_changes.stage_name,
        activities.activity_type_name,

        -- Step 2.1: first completed call while in "Qualified lead"
        min(activities.due_to_at) filter (
            where int_pipedrive_deal_stage_changes.stage_name = 'Qualified lead'
              and activities.activity_type_name = 'Sales Call 1'
              and activities.due_to_at >= int_pipedrive_deal_stage_changes.stage_entered_at
              and activities.due_to_at <  int_pipedrive_deal_stage_changes.stage_exited_at
        ) as sales_call_1_at,

        -- Step 3.1: first completed call while in "Needs Assessment"
        min(activities.due_to_at) filter (
            where int_pipedrive_deal_stage_changes.stage_name = 'Needs Assessment'
              and activities.activity_type_name = 'Sales Call 2'
              and activities.due_to_at >= int_pipedrive_deal_stage_changes.stage_entered_at
              and activities.due_to_at <  int_pipedrive_deal_stage_changes.stage_exited_at
        ) as sales_call_2_at

    from {{ ref ('int_pipedrive_deal_stage_changes')}} int_pipedrive_deal_stage_changes
    left join activities on activities.deal_id = int_pipedrive_deal_stage_changes.deal_id
    group by 1,2,3
),
final as (
    select deal_id, 
          stage_name,
          activity_type_name,
          sales_call_1_at as first_activity_executed_at
    from stage_activities
    where sales_call_1_at is not null

    union all

    select deal_id, 
          stage_name,
          activity_type_name,
          sales_call_2_at as first_activity_executed_at
    from stage_activities
    where sales_call_2_at is not null
)
select 
      {{ dbt_utils.generate_surrogate_key([
        'deal_id',
        'stage_name',
        'activity_type_name'
      ]) }} as deal_stage_activity_event_id,
      deal_id, 
      stage_name,
      activity_type_name,
      first_activity_executed_at
from final 

