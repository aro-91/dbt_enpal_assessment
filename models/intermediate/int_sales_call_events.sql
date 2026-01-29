with calls as (
    select
        activity_sk,
        deal_id,
        activity_type_key,
        due_at
    from {{ ref('stg_activity') }}
    where is_done = true
      and activity_type_key in ('meeting', 'sc_2')
),

final as (
    select
        activity_sk,
        deal_id,
        due_at as event_at,
        date_trunc('month', due_at)::date as event_month,
        case
            when activity_type_key = 'meeting' then 'Sales Call 1'
            when activity_type_key = 'sc_2' then 'Sales Call 2'
        end as kpi_name,
        case
            when activity_type_key = 'meeting' then '2.1'
            when activity_type_key = 'sc_2' then '3.1'
        end as funnel_step
    from calls
)

select
    activity_sk,
    deal_id,
    event_at,
    event_month,
    kpi_name,
    funnel_step
from final
