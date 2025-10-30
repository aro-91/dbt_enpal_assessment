{{ config(materialized='table') }}

with stage_events as (
    select
        d.deal_id,
        d.first_entered_at as occurred_at,
        case d.stage_id
            when 1 then 'Lead Generation'
            when 2 then 'Qualified Lead'
            when 3 then 'Needs Assessment'
            when 4 then 'Proposal/Quote Preparation'
            when 5 then 'Negotiation'
            when 6 then 'Closing'
            when 7 then 'Implementation/Onboarding'
            when 8 then 'Follow-up/Customer Success'
            when 9 then 'Renewal/Expansion'
        end as kpi_name,
        case d.stage_id
            when 1 then '1'
            when 2 then '2'
            when 3 then '3'
            when 4 then '4'
            when 5 then '5'
            when 6 then '6'
            when 7 then '7'
            when 8 then '8'
            when 9 then '9'
        end as funnel_step
    from {{ ref('int_deal_stage_history') }} d
),
call_events as (
    select
        c.deal_id,
        c.first_call_ts as occurred_at,
        c.call_name     as kpi_name,
        case
          when c.call_name = 'Sales Call 1' then '2.1'
          when c.call_name = 'Sales Call 2' then '3.1'
        end as funnel_step
    from {{ ref('int_activity_call_events') }} c
),
unioned as (
    select * from stage_events
    union all
    select * from call_events
)
select * from unioned
