with stage_history as (

    select
        deal_id,
        stage_id,
        stage_start_at
    from {{ ref('int_deal_stage_history') }}
    -- We only care about the event of entering the stage
    -- We do not filter 'is_active_stage' here, as we want the history, not just the current state.

),

funnel_steps as (

    select
        stage_id,
        funnel_step,
        funnel_order
    from {{ ref('int_funnel_stages') }}
    -- Filter out uncategorized stages that are not part of the 9 requested steps
    where funnel_order < 999 

),

deal_data as (

    select
        deal_id,
        created_at
    from {{ ref('int_deal_metadata') }}

),

-- Join all data to get the funnel steps and the monthly timestamp
joined_data as (

    select
        date_trunc('month', sh.stage_start_at)::date as month, 
        sh.deal_id,
        fs.funnel_step,
        fs.funnel_order
        
    from stage_history sh
    left join funnel_steps fs
        on sh.stage_id = fs.stage_id
    left join deal_data dd
        on sh.deal_id = dd.deal_id
    where fs.funnel_step is not null

),

-- Final Aggregation, Count deals entering each step per month
final_report as (

    select
        month,
        funnel_order,
        funnel_step as kpi_name, 
        count(distinct deal_id) as deals_count -- Count unique # of deals that entered this stage in this month


    from joined_data
    group by 1, 2, 3
    order by month, funnel_order

)

select
    month,
    kpi_name,
    funnel_order,
    deals_count
from final_report