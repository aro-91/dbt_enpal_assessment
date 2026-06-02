{{
    config(materialized='table')
}}

/*
    rep_deal_status_monthly
    ───────────────────────
    Dashboard-ready pivot of deal lifecycle: one row per deal × reporting month.

    NULL HANDLING (readability for BI consumers):
      - owner_name:        null → 'Unassigned'  (deal never had an assigned owner)
      - current_stage_name: null → 'Registered – Awaiting Stage Assignment'
                           (deal entered system but no stage event recorded yet)

    LOST REASON (carried forward):
      For a dashboard use case, showing lost_reason only in the month of loss
      makes filtering difficult. Here we carry it forward across all churned months
      so that filtering by lost_reason always returns the full deal history.
      The strict point-in-time version lives in int_deal_monthly_snapshot (intermediate).

    Grain: deal_id + reporting_month (unique).
*/

select
    snap.deal_id,
    snap.reporting_month,

    -- Owner (with null fallback for unassigned deals)
    snap.user_id,
    coalesce(snap.owner_name, 'Unassigned')                         as owner_name,

    -- Stage (with null fallback for deals not yet in the funnel)
    snap.stage_id,
    coalesce(
        snap.current_stage_name,
        'Registered – Awaiting Stage Assignment'
    )                                                               as current_stage_name,

    -- Churn flags
    snap.is_churned,
    snap.is_lost_this_month,

    -- Lost reason carried forward for all churned months (dashboard-friendly)
    -- Source: int_deal_summary, which holds the definitive lost_reason per deal
    case when snap.is_churned then ds.lost_reason_id  end           as lost_reason_id,
    case when snap.is_churned then ds.lost_reason_name end          as lost_reason_name,

    -- Exact timestamp of loss (only in the month it occurred)
    snap.lost_at

from {{ ref('int_deal_monthly_snapshot') }} snap
left join {{ ref('int_deal_summary') }} ds
    on ds.deal_id = snap.deal_id
order by
    snap.deal_id,
    snap.reporting_month
