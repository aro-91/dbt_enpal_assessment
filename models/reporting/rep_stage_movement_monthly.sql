{{
    config(materialized='table')
}}

/*
    rep_stage_movement_monthly
    ──────────────────────────
    Tracks how deals flow through funnel stages month over month.
    Designed as a dashboard table answering: for each stage in each month,
    how many deals arrived, how many stayed, and how many left?

    Grain: reporting_month × stage_id

    MOVEMENT CATEGORIES (from current-month perspective):
      new_to_funnel:   Deal received its first ever stage assignment this month.
                       These are genuinely new entries into the tracked funnel.
      stayed:          Deal was in this same stage last month and is still here.
                       High "stayed" counts signal pipeline stalling.
      moved_in:        Deal was in a DIFFERENT stage last month and moved into this one.
                       Represents stage progression (or regression).

    ATTRITION (from previous-month perspective):
      deals_lost_from_stage: Deals that were in this stage and got marked as lost this month.
                              Sourced from int_deal_summary.final_stage_id + lost_at.

    NOTE ON STAGE SKIPPING:
      Because deals can skip stages (e.g., go from stage 2 to stage 5 directly),
      "moved_in" includes both forward progressions and backward movements.
      To filter for progressions only, add: AND prev_stage_id < stage_id
*/

with snapshot_with_lag as (
    select
        deal_id,
        reporting_month,
        stage_id,
        current_stage_name,
        is_churned,
        is_lost_this_month,
        lag(stage_id) over (
            partition by deal_id
            order by reporting_month
        ) as prev_stage_id
    from {{ ref('int_deal_monthly_snapshot') }}
),

-- Classify each deal's relationship to its current stage this month
classified as (
    select
        deal_id,
        reporting_month,
        stage_id,
        current_stage_name,
        prev_stage_id,
        case
            when prev_stage_id is null then 'new_to_funnel'
            when stage_id = prev_stage_id  then 'stayed'
            else                                'moved_in'
        end as movement_type
    from snapshot_with_lag
    where stage_id is not null
      and not is_churned
),

-- Aggregate movement into current stages
stage_inflow as (
    select
        reporting_month,
        stage_id,
        current_stage_name,
        count(*)                                                  as total_active_deals,
        count(*) filter (where movement_type = 'new_to_funnel')   as deals_new_to_funnel,
        count(*) filter (where movement_type = 'stayed')          as deals_stayed,
        count(*) filter (where movement_type = 'moved_in')        as deals_moved_in
    from classified
    group by reporting_month, stage_id, current_stage_name
),

-- Deals lost from each stage this month (using final_stage_id from int_deal_summary)
deals_lost_from_stage as (
    select
        date_trunc('month', lost_at)::date  as reporting_month,
        final_stage_id                      as stage_id,
        count(*)                            as deals_lost_from_stage
    from {{ ref('int_deal_summary') }}
    where is_lost = true
    group by 1, 2
)

select
    si.reporting_month,
    si.stage_id,
    si.current_stage_name,

    -- Current month snapshot
    si.total_active_deals,

    -- How deals arrived in this stage
    si.deals_new_to_funnel,
    si.deals_stayed,
    si.deals_moved_in,

    -- How many deals were lost while in this stage this month
    coalesce(dl.deals_lost_from_stage, 0)   as deals_lost_from_stage

from stage_inflow si
left join deals_lost_from_stage dl
    on  dl.reporting_month = si.reporting_month
    and dl.stage_id        = si.stage_id
order by
    si.reporting_month,
    si.stage_id
