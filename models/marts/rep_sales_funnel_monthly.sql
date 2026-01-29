with stage_events as (
    select
        stage_entered_month as month,
        stage_name as kpi_name,
        stage_id::text as funnel_step,
        deal_id
    from {{ ref('int_deal_stage_events') }}
),

call_events as (
    select
        event_month as month,
        kpi_name,
        funnel_step,
        deal_id
    from {{ ref('int_sales_call_events') }}
),

unioned as (
    select * from stage_events
    union all
    select * from call_events
)

select
    month,
    kpi_name,
    funnel_step,
    count(distinct deal_id) as deals_count
from unioned
group by 1,2,3
