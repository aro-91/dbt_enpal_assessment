{{
    config(materialized='table')
}}

/*
    Core intermediate model: one row per deal × calendar month.

    For each month, we carry forward the most recent stage_id and user_id
    as of the last day of that month (point-in-time snapshot).

    Logic:
      1. Extract typed events from the EAV deal_changes table.
      2. Build a date spine covering all months in the data.
      3. Cross-join each deal with every month from its creation month onward.
      4. Use DISTINCT ON to resolve the "latest value as-of" for stage and user.
      5. Join lost_reason so the month a deal was lost is annotated.
*/

with stage_events as (
    select
        deal_id,
        changed_at,
        new_value::int as stage_id
    from {{ ref('stg_deal_changes') }}
    where field_key = 'stage_id'
),

user_events as (
    select
        deal_id,
        changed_at,
        new_value::int as user_id
    from {{ ref('stg_deal_changes') }}
    where field_key = 'user_id'
),

lost_events as (
    -- Deduplicate to one lost_reason event per (deal, month)
    -- Mirrors the same fix in int_deal_summary for single-event-per-deal grain
    select distinct on (deal_id, date_trunc('month', changed_at)::date)
        deal_id,
        changed_at                                               as lost_at,
        new_value::int                                           as lost_reason_id,
        date_trunc('month', changed_at)::date                   as lost_month
    from {{ ref('stg_deal_changes') }}
    where field_key = 'lost_reason'
    order by deal_id, date_trunc('month', changed_at)::date, changed_at desc
),

deal_start as (
    -- earliest record for a deal defines when it was created
    select
        deal_id,
        date_trunc('month', min(changed_at))::date as first_month
    from {{ ref('stg_deal_changes') }}
    group by deal_id
),

-- Generate a monthly date spine across the full history window
date_spine as (
    select
        date_trunc('month', gs)::date as reporting_month
    from generate_series(
        (select min(changed_at) from {{ ref('stg_deal_changes') }})::date,
        (select max(changed_at) from {{ ref('stg_deal_changes') }})::date,
        '1 month'::interval
    ) as gs
),

-- Each deal appears once per month from its creation month onward
deal_months as (
    select
        ds.deal_id,
        dm.reporting_month
    from deal_start ds
    inner join date_spine dm
        on dm.reporting_month >= ds.first_month
),

-- Most recent stage_id as of the end of each reporting month
stage_per_month as (
    select distinct on (dm.deal_id, dm.reporting_month)
        dm.deal_id,
        dm.reporting_month,
        se.stage_id
    from deal_months dm
    left join stage_events se
        on  se.deal_id    = dm.deal_id
        and se.changed_at <= (dm.reporting_month + interval '1 month - 1 second')
    order by
        dm.deal_id,
        dm.reporting_month,
        se.changed_at desc nulls last
),

-- Lost reason labels parsed from fields table (no hardcoding)
-- DISTINCT ON guards against duplicate option rows in the fields source table
lost_reason_labels as (
    select distinct on (option_id)
        option_id    as lost_reason_id,
        option_label as lost_reason_name
    from {{ ref('stg_fields') }}
    where field_key = 'lost_reason'
    order by option_id
),

-- Most recent user_id (owner) as of the end of each reporting month
user_per_month as (
    select distinct on (dm.deal_id, dm.reporting_month)
        dm.deal_id,
        dm.reporting_month,
        ue.user_id
    from deal_months dm
    left join user_events ue
        on  ue.deal_id    = dm.deal_id
        and ue.changed_at <= (dm.reporting_month + interval '1 month - 1 second')
    order by
        dm.deal_id,
        dm.reporting_month,
        ue.changed_at desc nulls last
)

select
    sm.deal_id,
    sm.reporting_month,
    sm.stage_id,
    st.stage_name                                           as current_stage_name,
    um.user_id,
    u.user_name                                             as owner_name,
    -- lost_reason only populated in the month the deal was lost
    -- label sourced from stg_fields (no hardcoding)
    le.lost_reason_id,
    lrl.lost_reason_name,
    le.lost_at,
    case when le.lost_at is not null then true else false end as is_lost_this_month,
    -- flag: has this deal ever been lost as of this month?
    case
        when exists (
            select 1 from lost_events le2
            where le2.deal_id = sm.deal_id
              and le2.lost_month <= sm.reporting_month
        )
        then true
        else false
    end                                                     as is_churned
from stage_per_month sm
left join user_per_month um
    on  um.deal_id         = sm.deal_id
    and um.reporting_month = sm.reporting_month
left join {{ ref('stg_stages') }} st
    on st.stage_id = sm.stage_id
left join {{ ref('stg_users') }} u
    on u.user_id = um.user_id
left join lost_events le
    on  le.deal_id    = sm.deal_id
    and le.lost_month = sm.reporting_month
left join lost_reason_labels lrl
    on lrl.lost_reason_id = le.lost_reason_id
