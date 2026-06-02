{{
    config(materialized='table')
}}

/*
    rep_salesperson_performance
    ───────────────────────────
    Monthly performance scorecard per salesperson.

    Grain: user_id × reporting_month

    Key metrics:
      - deals_in_pipeline:     active (non-churned) deals owned this month
      - deals_lost:            deals where this user was owner when lost
      - deals_reached_closing: deals that reached stage 6 (Closing) this month
      - deals_won:             deals that reached stage 9 (Renewal/Expansion) this month
      - total_deals_worked:    all-time distinct deals ever assigned to this rep
      - conversion_rate_pct:   deals_won / (deals_won + deals_lost) × 100
      - avg_days_to_loss:      avg pipeline age for deals lost by this rep this month
      - avg_days_to_win:       avg pipeline age for deals won by this rep this month
      - most_common_lost_stage / most_common_lost_reason: all-time coaching signals
*/

with monthly_pipeline as (
    select
        snap.reporting_month,
        snap.user_id,
        snap.owner_name,
        count(distinct snap.deal_id) filter (where not snap.is_churned)     as deals_in_pipeline,
        count(distinct snap.deal_id) filter (where snap.is_lost_this_month) as deals_lost_this_month
    from {{ ref('int_deal_monthly_snapshot') }} snap
    where snap.user_id is not null
    group by
        snap.reporting_month,
        snap.user_id,
        snap.owner_name
),

deals_reaching_closing as (
    select
        date_trunc('month', dc.changed_at)::date  as reporting_month,
        snap.user_id,
        count(distinct dc.deal_id)                as deals_reached_closing
    from {{ ref('stg_deal_changes') }} dc
    inner join {{ ref('int_deal_monthly_snapshot') }} snap
        on  snap.deal_id         = dc.deal_id
        and snap.reporting_month = date_trunc('month', dc.changed_at)::date
    where dc.field_key = 'stage_id'
      and dc.new_value = '6'
    group by 1, 2
),

deals_won as (
    select
        date_trunc('month', dc.changed_at)::date  as reporting_month,
        snap.user_id,
        count(distinct dc.deal_id)                as deals_won
    from {{ ref('stg_deal_changes') }} dc
    inner join {{ ref('int_deal_monthly_snapshot') }} snap
        on  snap.deal_id         = dc.deal_id
        and snap.reporting_month = date_trunc('month', dc.changed_at)::date
    where dc.field_key = 'stage_id'
      and dc.new_value = '9'
    group by 1, 2
),

avg_deal_duration as (
    -- Average days in pipeline for deals lost this month, attributed to last owner
    select
        date_trunc('month', ds.lost_at)::date as reporting_month,
        ds.owner_user_id                      as user_id,
        round(avg(ds.days_in_pipeline), 1)    as avg_days_to_loss
    from {{ ref('int_deal_summary') }} ds
    where ds.is_lost = true
    group by 1, 2
),

avg_days_to_win as (
    -- Average days from deal creation to reaching stage 9, per rep per month
    -- Uses the stage_id = 9 event timestamp as the "win date"
    select
        date_trunc('month', dc.changed_at)::date          as reporting_month,
        snap.user_id,
        round(avg(
            dc.changed_at::date - ds.deal_created_at::date
        ), 1)                                             as avg_days_to_win
    from {{ ref('stg_deal_changes') }} dc
    inner join {{ ref('int_deal_summary') }} ds
        on ds.deal_id = dc.deal_id
    inner join {{ ref('int_deal_monthly_snapshot') }} snap
        on  snap.deal_id         = dc.deal_id
        and snap.reporting_month = date_trunc('month', dc.changed_at)::date
    where dc.field_key = 'stage_id'
      and dc.new_value = '9'
    group by 1, 2
),

-- All-time count of distinct deals ever owned by each rep
-- Uses user_id events so a rep gets credit even if they later transferred the deal
total_deals_worked as (
    select
        new_value::int              as user_id,
        count(distinct deal_id)     as total_deals_worked
    from {{ ref('stg_deal_changes') }}
    where field_key = 'user_id'
    group by 1
),

top_lost_stage as (
    select distinct on (owner_user_id)
        owner_user_id    as user_id,
        final_stage_name as most_common_lost_stage
    from {{ ref('int_deal_summary') }}
    where is_lost = true
    group by owner_user_id, final_stage_id, final_stage_name
    order by owner_user_id, count(*) desc
),

top_lost_reason as (
    select distinct on (owner_user_id)
        owner_user_id    as user_id,
        lost_reason_name as most_common_lost_reason
    from {{ ref('int_deal_summary') }}
    where is_lost = true
    group by owner_user_id, lost_reason_id, lost_reason_name
    order by owner_user_id, count(*) desc
)

select
    mp.reporting_month,
    mp.user_id,
    mp.owner_name,

    -- Volume
    mp.deals_in_pipeline,
    mp.deals_lost_this_month                                    as deals_lost,
    coalesce(drc.deals_reached_closing, 0)                      as deals_reached_closing,
    coalesce(dw.deals_won, 0)                                   as deals_won,
    coalesce(tdw.total_deals_worked, 0)                         as total_deals_worked,

    -- Conversion rate: won / (won + lost) for this month
    case
        when coalesce(dw.deals_won, 0) + mp.deals_lost_this_month = 0 then null
        else round(
            100.0 * coalesce(dw.deals_won, 0)
            / (coalesce(dw.deals_won, 0) + mp.deals_lost_this_month),
            1
        )
    end                                                         as conversion_rate_pct,

    -- Deal velocity
    add.avg_days_to_loss,
    adw.avg_days_to_win,

    -- All-time coaching signals
    tls.most_common_lost_stage,
    tlr.most_common_lost_reason

from monthly_pipeline mp
left join deals_reaching_closing drc
    on  drc.reporting_month = mp.reporting_month
    and drc.user_id         = mp.user_id
left join deals_won dw
    on  dw.reporting_month  = mp.reporting_month
    and dw.user_id          = mp.user_id
left join avg_deal_duration add
    on  add.reporting_month = mp.reporting_month
    and add.user_id         = mp.user_id
left join avg_days_to_win adw
    on  adw.reporting_month = mp.reporting_month
    and adw.user_id         = mp.user_id
left join total_deals_worked tdw
    on tdw.user_id = mp.user_id
left join top_lost_stage tls
    on tls.user_id = mp.user_id
left join top_lost_reason tlr
    on tlr.user_id = mp.user_id
order by
    mp.reporting_month,
    mp.deals_in_pipeline desc
