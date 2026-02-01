with stage_events as (

    select
        deal_id,
        stage_entered_at as event_time,
        case
            when stage_name = 'Lead Generation'
                then 'Step 1: Lead Generation'
            when stage_name = 'Qualified lead'
                then 'Step 2: Qualified Lead'
            when stage_name = 'Needs Assessment'
                then 'Step 3: Needs Assessment'
            when stage_name = 'Proposal/Quote Preparation'
                then 'Step 4: Proposal/Quote Preparation'
            when stage_name = 'Negotiation'
                then 'Step 5: Negotiation'
            when stage_name = 'Closing'
                then 'Step 6: Closing'
            when stage_name = 'Implementation/Onboarding'
                then 'Step 7: Implementation/Onboarding'
            when stage_name = 'Follow-up/Customer Success'
                then 'Step 8: Follow-up/Customer Success'
            when stage_name = 'Renewal/Expansion'
                then 'Step 9: Renewal/Expansion'
            else 'Unknown'
        end as funnel_step
    from {{ ref('int_pipedrive_deal_stage_changes') }}

),

activity_events as (

    select
        deal_id,
        first_activity_executed_at as event_time,
        case
            when stage_name = 'Qualified lead' and activity_type_name = 'Sales Call 1'
                then 'Step 2.1: Sales Call 1'
            when stage_name = 'Needs Assessment' and activity_type_name = 'Sales Call 2'
                then 'Step 3.1: Sales Call 2'
            else 'Unknown'
        end as funnel_step
    from {{ ref('int_pipedrive_deal_activity_changes') }}

),

funnel_events as (

    select * from stage_events
    union all
    select * from activity_events

)

select
    date_trunc('month', event_time)::date as month,
    'deals_by_funnel_step' as kpi_name,
    funnel_step,
    count(distinct deal_id)::bigint as deals_count
from funnel_events
where funnel_step <> 'Unknown'
group by 1, 2, 3
order by month desc, funnel_step
