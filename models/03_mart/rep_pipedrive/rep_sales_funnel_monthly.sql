{#
    Required deliverable.

    Purpose: deals and calls per funnel step of each month when reached
    (or completed). Shows how deals move through the funnel over time.
    Replicates Pipedrive's Deal Progress report.

    Grain: one row per month and funnel_step.
#}

with trns_deal_stages_backfill as (

    select * from {{ ref('trns_deal_stages_backfill') }}

),

trns_deal_sales_calls_mapping as (

    select * from {{ ref('trns_deal_sales_calls_mapping') }}

),

trns_deal_stage_funnel as (

    select * from {{ ref('trns_deal_stage_funnel') }}

),

funnel_steps as (

    select * from {{ ref('funnel_steps') }}

),

stage_events as (
    {#- each stage_id, and the month it was reached, per deal #}

    select
        deal_id
        , stage_id
        , date_trunc('month', reached_at)::date    as month

    from trns_deal_stages_backfill

),

call_events as (
    {#- the same, for sales calls, keyed by the month they were completed #}

    select
        deal_id
        , activity_type_name
        , date_trunc('month', completed_at)::date    as month

    from trns_deal_sales_calls_mapping

),

funnel_events as (
    {#- every stage-reach and call-completion event, tagged with its
       funnel_step/kpi_name and a source_type literal, so both sides can
       share one spine and one aggregation downstream. Stage labels come
       from live field metadata, not the seed; the seed still supplies
       the two sales-call sub-steps, since there's no native Pipedrive
       source for them #}

    select
        stage_events.deal_id
        , stage_events.month
        , trns_deal_stage_funnel.stage_id::text    as funnel_step
        , trns_deal_stage_funnel.kpi_name
        , 'stage'    as source_type

    from stage_events
    inner join trns_deal_stage_funnel
        on stage_events.stage_id = trns_deal_stage_funnel.stage_id

    union all

    select
        call_events.deal_id
        , call_events.month
        , funnel_steps.funnel_step::text    as funnel_step
        , funnel_steps.kpi_name
        , 'activity'    as source_type

    from call_events
    inner join funnel_steps
        on call_events.activity_type_name = funnel_steps.activity_type_name
        and funnel_steps.source_type = 'activity'

),

source_bounds as (
    {#- each source's own real date range, in one pass, so the spine
       below can trim each source back to it -- stage data runs through
       the full deal_changes history; activity data stops months earlier #}

    select
        source_type
        , min(month)    as min_month
        , max(month)    as max_month

    from funnel_events
    group by 1

),

spine as (
    {#- one calendar spine over the full combined range; grid below trims
       each source back to its own real range via source_bounds #}

    select month::date as month
    from (
        {{ month_spine(
            "(select min(min_month) from source_bounds)"
            , "(select max(max_month) from source_bounds)"
        ) }}
    ) as month_spine

),

grid as (
    {#- every (month, funnel step) combination, whether or not any deal
       actually reached it that month -- trimmed per source to that
       source's own real date range, so the model does not invent zeros
       in months where a source has no data at all #}

    select
        spine.month
        , trns_deal_stage_funnel.stage_id::text    as funnel_step
        , trns_deal_stage_funnel.kpi_name

    from spine
    inner join source_bounds
        on source_bounds.source_type = 'stage'
        and spine.month
            between source_bounds.min_month and source_bounds.max_month
    cross join trns_deal_stage_funnel

    union all

    select
        spine.month
        , funnel_steps.funnel_step::text    as funnel_step
        , funnel_steps.kpi_name

    from spine
    inner join source_bounds
        on source_bounds.source_type = 'activity'
        and spine.month
            between source_bounds.min_month and source_bounds.max_month
    cross join funnel_steps
    where funnel_steps.source_type = 'activity'

),

counts as (
    {#- aggregate deals per funnel step and month #}

    select
        month
        , funnel_step
        , kpi_name
        , count(distinct deal_id)::int    as deals_count

    from funnel_events
    group by 1, 2, 3

),

final as (
    {#- left join the real counts onto the full grid, zero-filling gaps #}

    select
        grid.month
        , grid.kpi_name
        , grid.funnel_step
        , coalesce(counts.deals_count, 0)    as deals_count

    from grid
    left join counts
        on grid.month = counts.month
        and grid.funnel_step = counts.funnel_step

)

select * from final
