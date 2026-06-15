with int_deal_stage_history as (
    select * from {{ ref('int_deal_stage_history') }}
)

, int_deal_sales_call as (
    select * from {{ ref('int_deal_sales_call') }}
)

, stg_pipedrive__stages as (
    select * from {{ ref('stg_pipedrive__stages') }}
)

-- The real counts: how many deals reached each step each month. These are
-- "sparse", i.e. there's only a row where at least one deal showed up.
, stage_counts as (
    select
        month
        , stage_name as kpi_name
        , funnel_step
        , count(distinct deal_id) as deals_count
    from int_deal_stage_history
    group by 1, 2, 3
)

, sales_call_counts as (
    select
        month
        , kpi_name
        , funnel_step
        , count(distinct deal_id) as deals_count
    from int_deal_sales_call
    group by 1, 2, 3
)

-- The list of steps in each group. Stage steps come from the stages table so
-- all 9 are always there, even a stage no deal happened to reach.
, stage_steps as (
    select
        cast(stage_id as numeric(3, 1)) as funnel_step
        , stage_name as kpi_name
    from stg_pipedrive__stages
)

, sales_call_steps as (
    select distinct
        funnel_step
        , kpi_name
    from int_deal_sales_call
)

/*
    A continuous list of months to fill the gaps so every month shows every
    step (with 0 where nothing happened). The bounds below just need to be wide
    enough to cover the data; we trim to the real range per group further down,
    so a deal source that ends early (the activities stop in Sep 2024) never
    gets fake 0 rows past its data.
*/
, month_spine as (
    select cast(date_month as date) as month
    from (
        {{ dbt_utils.date_spine(
            datepart="month",
            start_date="cast('2024-01-01' as date)",
            end_date="cast('2026-01-01' as date)"
        ) }}
    ) as spine
)

-- The real month range each group actually has data for.
, stage_month_range as (
    select min(month) as first_month, max(month) as last_month from stage_counts
)

, sales_call_month_range as (
    select min(month) as first_month, max(month) as last_month from sales_call_counts
)

-- Every stage step in every month it could have data, and the same for calls.
, stage_grid as (
    select
        month_spine.month
        , stage_steps.funnel_step
        , stage_steps.kpi_name
    from month_spine
    cross join stage_steps
    cross join stage_month_range
    where month_spine.month between stage_month_range.first_month and stage_month_range.last_month
)

, sales_call_grid as (
    select
        month_spine.month
        , sales_call_steps.funnel_step
        , sales_call_steps.kpi_name
    from month_spine
    cross join sales_call_steps
    cross join sales_call_month_range
    where month_spine.month between sales_call_month_range.first_month and sales_call_month_range.last_month
)

, grid as (
    select * from stage_grid
    union all
    select * from sales_call_grid
)

, all_counts as (
    select * from stage_counts
    union all
    select * from sales_call_counts
)

-- Put the real counts onto the full grid; anything missing becomes 0.
, final as (
    select
        grid.month
        , grid.kpi_name
        , grid.funnel_step
        , coalesce(all_counts.deals_count, 0) as deals_count
    from grid
    left join all_counts
        on grid.month = all_counts.month
        and grid.funnel_step = all_counts.funnel_step
        and grid.kpi_name = all_counts.kpi_name
)

select * from final
