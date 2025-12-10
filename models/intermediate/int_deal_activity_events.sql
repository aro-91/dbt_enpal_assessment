with activities as (
    select * from {{ ref('stg_activities') }}
),

activity_events as (
    select
        deal_id,
        activity_timestamp,
        activity_type,
        is_done,
        to_char(date_trunc('month', activity_timestamp), 'YYYY-MM') as event_month,
        case
            when activity_type = 'meeting' then 'Sales Call 1'
            when activity_type = 'sc_2' then 'Sales Call 2'
            else null
        end as activity_name
    from activities
    where activity_type in ('meeting', 'sc_2')
      and is_done = true
)

select * from activity_events
