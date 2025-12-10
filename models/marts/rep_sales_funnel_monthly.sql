with stage_events as (
    select * from {{ ref('int_deal_stage_events') }}
),

activity_events as (
    select * from {{ ref('int_deal_activity_events') }}
),

-- Stage-based funnel steps
stage_funnel as (
    select
        event_month as month,
        stage_name as kpi_name,
        case stage_id
            when 1 then 'Step 1'
            when 2 then 'Step 2'
            when 3 then 'Step 3'
            when 4 then 'Step 4'
            when 5 then 'Step 5'
            when 6 then 'Step 6'
            when 7 then 'Step 7'
            when 8 then 'Step 8'
            when 9 then 'Step 9'
        end as funnel_step,
        count(distinct deal_id) as deals_count
    from stage_events
    group by event_month, stage_name, stage_id
),

-- Activity-based funnel steps (Sales Call 1 & 2)
activity_funnel as (
    select
        event_month as month,
        activity_name as kpi_name,
        case activity_name
            when 'Sales Call 1' then 'Step 2.1'
            when 'Sales Call 2' then 'Step 3.1'
        end as funnel_step,
        count(distinct deal_id) as deals_count
    from activity_events
    group by event_month, activity_name
),

-- Combine both
combined_funnel as (
    select * from stage_funnel
    union all
    select * from activity_funnel
)

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from combined_funnel
order by month, funnel_step
