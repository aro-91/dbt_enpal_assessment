{#
    PROPOSED REPORT. Not part of the data model: run manually, not built
    or tested. If approved, promote into models/03_mart/ with a
    schema.yml entry and its dbt_utils tests.

    Maps to Pipedrive's Deal Duration report. See
    support.pipedrive.com/en/article/insights-reports-deal-duration.

    Grain: one row per month and funnel_step, bucketed by the month a
    deal entered the stage.

    Covers stage steps 1 to 8. Stage 9 has no next stage to bound it, and
    a sales call is a point event with no duration to measure.

    deals_count counts only deals with a known exit from the stage.
    Deals still sitting in one are right-censored and excluded, so this
    count runs below the matching count in rep_sales_funnel_monthly.
#}

with trns_deal_stages_backfill as (

    select * from {{ ref('trns_deal_stages_backfill') }}

),

funnel_steps as (

    select * from {{ ref('funnel_steps') }}

),

with_next_stage as (
    {#- trns_deal_stages_backfill is gap-free by construction (see the
       backfill logic), so next stage_id here is always exactly
       stage_id + 1 -- never a further skip #}

    select
        deal_id
        , stage_id
        , reached_at
        , lead(reached_at) over (partition by deal_id order by stage_id)    as next_reached_at

    from trns_deal_stages_backfill

),

durations as (
    {#- a stage's duration is only known once a deal has moved past it --
       otherwise it's right-censored (the deal might still be sitting
       there). Pipedrive's own Duration report handles this by defaulting
       to won/lost deals only; this dataset has no reliable won/lost
       field, so we use the closest available equivalent: require a known
       exit. This also excludes stage 9 automatically (nothing to move on
       to) #}

    select
        deal_id
        , stage_id
        , date_trunc('month', reached_at)::date                              as month
        , extract(epoch from (next_reached_at - reached_at)) / 86400.0    as duration_days

    from with_next_stage
    where next_reached_at is not null

),

agg as (

    select
        month
        , stage_id
        , avg(duration_days)          as avg_days_in_stage
        , count(distinct deal_id)     as deals_count

    from durations
    group by 1, 2

),

final as (

    select
        agg.month
        , funnel_steps.kpi_name
        , funnel_steps.funnel_step
        , round(agg.avg_days_in_stage, 1)    as avg_days_in_stage
        , agg.deals_count

    from agg
    inner join funnel_steps
        on agg.stage_id = funnel_steps.stage_id
        and funnel_steps.source_type = 'stage'

)

select * from final
order by 1, 3
