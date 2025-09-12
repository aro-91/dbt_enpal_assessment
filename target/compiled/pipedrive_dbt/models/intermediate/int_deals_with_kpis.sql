

with deal_stage_history as (
    select 
        deal_stage_change_id, 
        deal_id, 
        stage_id, 
        stage_name, 
        valid_from,
    from pipedrive_analytics.intermediate.int_deal_stage_history
    
        where valid_from > (select max(valid_from) from pipedrive_analytics.intermediate.int_deals_with_kpis)
        
),

activity_flags as (
    select
        a.deal_id,
        max(case when at.activity_name = 'Sales Call 1' and a.is_done then 1 else 0 end) as sales_call_1_done,
        max(case when at.activity_name = 'Sales Call 2' and a.is_done then 1 else 0 end) as sales_call_2_done
    from pipedrive_analytics.staging.stg_activity a
    join pipedrive_analytics.staging.stg_activity_types at
      on a.activity_type = at.activity_type_key
    where a.due_to_timestamp >= dateadd(day, -30, current_date)
    group by a.deal_id
),

deals_with_kpis as (
    select
        dsh.deal_stage_change_id,
        dsh.deal_id,
        dsh.stage_id,
        dsh.stage_name,
        dsh.valid_from,
        dsh.stage_name as funnel_step,
        case
            when dsh.stage_name = 'Qualified lead' and af.sales_call_1_done = 1 then 'Step 2.1: Sales Call 1'
            when dsh.stage_name = 'Needs Assessment' and af.sales_call_2_done = 1 then 'Step 3.1: Sales Call 2'
            else null
        end as funnel_sub_step
    from deal_stage_history dsh
    left join activity_flags af on dsh.deal_id = af.deal_id
)

select *
from deals_with_kpis