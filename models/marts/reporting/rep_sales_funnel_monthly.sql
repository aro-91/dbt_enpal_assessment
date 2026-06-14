with int_deal_stage_history as (
    select * from {{ ref('int_deal_stage_history') }}
)

, int_deal_sales_call as (
    select * from {{ ref('int_deal_sales_call') }}
)

, stage_milestones as (
    select
        month
        , stage_name as kpi_name
        , funnel_step
        , deal_id
    from int_deal_stage_history
)

, sales_calls as (
    select
        month
        , kpi_name
        , funnel_step
        , deal_id
    from int_deal_sales_call
)

, funnel_events as (
    select * from stage_milestones
    union all
    select * from sales_calls
)

, final as (
    select
        month
        , kpi_name
        , funnel_step
        , count(distinct deal_id) as deals_count
    from funnel_events
    group by 1, 2, 3
)

select * from final
