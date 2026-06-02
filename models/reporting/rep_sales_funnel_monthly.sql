{{
    config(materialized='table')
}}

/*
    rep_sales_funnel_monthly
    ────────────────────────
    Required by the assessment README.
    Columns: month, kpi_name, funnel_step, deals_count

    Grain: one row per reporting_month × funnel step (stage).

    Definition: deals_count = number of distinct deals that were
    active at a given funnel stage at the end of the month.
    A deal is counted in a stage if that was its most recent stage
    as of month end and it had not yet churned.

    The 9 funnel steps map directly to the stages table.
    Steps 2.1 and 3.1 are derived from the activity table, filtered by
    activity type as defined in activity_types:
      - Step 2.1 (Sales Call 1): activity_type = 'meeting', deal in stage 2
      - Step 3.1 (Sales Call 2): activity_type = 'sc_2',    deal in stage 3

    ⚠️  DATA QUALITY NOTE — Steps 2.1 and 3.1:
    Only 8 deal IDs overlap between the activity and deal_changes tables.
    Even with the correct activity type filters applied, both steps return
    zero counts because those 8 deals' activity timestamps do not align with
    the months those deals were in stages 2 or 3.
    The modelling logic is correct — the limitation is in source data coverage.
    Recommended action: raise with source engineering to confirm both exports
    share the same deal population and date range.
*/

with active_deals_per_stage as (
    -- Deals at each stage at end of month, excluding already-lost deals
    select
        snap.reporting_month                        as month,
        snap.stage_id,
        snap.current_stage_name,
        count(distinct snap.deal_id)                as deals_count
    from {{ ref('int_deal_monthly_snapshot') }} snap
    where snap.stage_id is not null
      and snap.is_churned = false
    group by
        snap.reporting_month,
        snap.stage_id,
        snap.current_stage_name
),

-- Sales Call 1 (step 2.1): activity_type 'meeting' per activity_types table,
-- completed, on a deal while it was in stage 2 (Qualified Lead)
sales_call_1 as (
    select
        date_trunc('month', a.due_at)::date         as month,
        count(distinct a.deal_id)                   as deals_count
    from {{ ref('stg_activity') }} a
    inner join {{ ref('stg_activity_types') }} at
        on at.type_key      = a.activity_type
    inner join {{ ref('int_deal_monthly_snapshot') }} snap
        on  snap.deal_id        = a.deal_id
        and snap.reporting_month = date_trunc('month', a.due_at)::date
        and snap.stage_id        = 2
    where a.done = true
      and a.activity_type = 'meeting'
    group by 1
),

-- Sales Call 2 (step 3.1): activity_type 'sc_2' per activity_types table,
-- completed, on a deal while it was in stage 3 (Needs Assessment)
sales_call_2 as (
    select
        date_trunc('month', a.due_at)::date         as month,
        count(distinct a.deal_id)                   as deals_count
    from {{ ref('stg_activity') }} a
    inner join {{ ref('stg_activity_types') }} at
        on at.type_key      = a.activity_type
    inner join {{ ref('int_deal_monthly_snapshot') }} snap
        on  snap.deal_id        = a.deal_id
        and snap.reporting_month = date_trunc('month', a.due_at)::date
        and snap.stage_id        = 3
    where a.done = true
      and a.activity_type = 'sc_2'
    group by 1
),

-- Union all funnel step rows into the required shape
funnel_rows as (

    -- Steps 1–9: active deals at each stage
    select
        month,
        current_stage_name                          as kpi_name,
        concat('Step ', cast(stage_id as varchar))  as funnel_step,
        deals_count
    from active_deals_per_stage

    union all

    -- Step 2.1: Sales Call 1
    select
        month,
        'Sales Call 1'                              as kpi_name,
        'Step 2.1'                                  as funnel_step,
        deals_count
    from sales_call_1

    union all

    -- Step 3.1: Sales Call 2
    select
        month,
        'Sales Call 2'                              as kpi_name,
        'Step 3.1'                                  as funnel_step,
        deals_count
    from sales_call_2
)

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from funnel_rows
order by
    month,
    funnel_step
