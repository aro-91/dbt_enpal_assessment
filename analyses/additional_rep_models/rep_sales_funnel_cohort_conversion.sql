{#
    PROPOSED REPORT. Not part of the data model: run manually, not built
    or tested. If approved, promote into models/03_mart/ with a
    schema.yml entry, its dbt_utils tests, and a monotonicity check on
    conversion_pct.

    Maps to Pipedrive's Deal Conversion report.

    Grain: one row per cohort_month and funnel_step.

    Covers stage steps 1 to 9. The Sales Call sub-steps cannot be added:
    activity.deal_id and deal_changes.deal_id overlap on 8 ids of 4,572,
    so a call cannot be attributed to a cohort at any real scale.

    rep_sales_funnel_monthly buckets by the month a stage was reached,
    mixing many cohorts into one row. It answers "how many deals reached
    stage 4 in March". This answers "what share of a cohort converts from
    stage 3 to stage 4".
#}

with stg_pipedrive__deal_changes as (

    select * from {{ ref('stg_pipedrive__deal_changes') }}

),

trns_deal_stages_backfill as (

    select * from {{ ref('trns_deal_stages_backfill') }}

),

funnel_steps as (

    select * from {{ ref('funnel_steps') }}

),

deal_cohorts as (

    select
        deal_id
        , date_trunc('month', changed_at)::date    as cohort_month

    from stg_pipedrive__deal_changes
    where changed_field_key = 'add_time'

),

deal_stages_reached as (
    {#- cohort/conversion reporting isn't time-boxed by month the way
       rep_sales_funnel_monthly is -- it only cares whether the deal ever
       got there, matching Pipedrive's own Deal Conversion semantics #}

    select distinct
        deal_id
        , stage_id

    from trns_deal_stages_backfill

),

cohort_sizes as (

    select
        cohort_month
        , count(distinct deal_id)    as cohort_deal_count

    from deal_cohorts
    group by 1

),

reached_counts as (

    select
        deal_cohorts.cohort_month
        , deal_stages_reached.stage_id
        , count(distinct deal_cohorts.deal_id)    as deals_reached

    from deal_cohorts
    inner join deal_stages_reached
        on deal_cohorts.deal_id = deal_stages_reached.deal_id
    group by 1, 2

),

grid as (

    select
        cohort_sizes.cohort_month
        , funnel_steps.stage_id
        , funnel_steps.funnel_step
        , funnel_steps.kpi_name

    from cohort_sizes
    cross join funnel_steps
    where funnel_steps.source_type = 'stage'

),

final as (

    select
        grid.cohort_month
        , grid.kpi_name
        , grid.funnel_step
        , coalesce(reached_counts.deals_reached, 0)                                as deals_count
        , cohort_sizes.cohort_deal_count
        , round(
            100.0 * coalesce(reached_counts.deals_reached, 0)
            / nullif(cohort_sizes.cohort_deal_count, 0)
            , 1
          )    as conversion_pct

    from grid
    inner join cohort_sizes
        on grid.cohort_month = cohort_sizes.cohort_month
    left join reached_counts
        on grid.cohort_month = reached_counts.cohort_month
        and grid.stage_id = reached_counts.stage_id

)

select * from final
order by 1, 3
