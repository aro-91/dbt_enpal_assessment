{{
    config(materialized='table')
}}

/*
    One row per deal summarising its full lifecycle.
    Used by all reporting models for deal-level aggregations.

    Key fields:
      - deal_created_at: when the deal entered the system
      - final_stage_id: the stage the deal was in when it was lost (or is currently in)
      - lost_at / lost_reason_id: populated if the deal was lost
      - owner_user_id: the last assigned owner
      - days_in_pipeline: total calendar days from creation to loss (or data horizon)
      - is_lost: boolean flag
*/

with deal_created as (
    select
        deal_id,
        min(changed_at) as deal_created_at
    from {{ ref('stg_deal_changes') }}
    where field_key = 'add_time'
    group by deal_id
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

-- Last stage before or at the time of loss
last_stage as (
    select distinct on (deal_id)
        deal_id,
        new_value::int as final_stage_id,
        changed_at     as final_stage_changed_at
    from {{ ref('stg_deal_changes') }}
    where field_key = 'stage_id'
    order by deal_id, changed_at desc
),

lost_events as (
    -- SOURCE DATA QUALITY: some deals have multiple lost_reason events
    -- (e.g., a deal re-opened and re-closed, or duplicate API writes).
    -- We take the most recent lost_reason event per deal to avoid fan-out
    -- on the final join, which would violate the one-row-per-deal grain.
    select distinct on (deal_id)
        deal_id,
        changed_at     as lost_at,
        new_value::int as lost_reason_id
    from {{ ref('stg_deal_changes') }}
    where field_key = 'lost_reason'
    order by deal_id, changed_at desc
),

last_owner as (
    select distinct on (deal_id)
        deal_id,
        new_value::int as owner_user_id
    from {{ ref('stg_deal_changes') }}
    where field_key = 'user_id'
    order by deal_id, changed_at desc
),

-- All lost reasons ever recorded for a deal, in chronological order
-- Useful for deals that were re-opened and re-lost with different reasons
all_lost_reasons as (
    select
        dc.deal_id,
        string_agg(
            lrl.lost_reason_name,
            ' → ' order by dc.changed_at
        ) as all_lost_reasons_history
    from {{ ref('stg_deal_changes') }} dc
    inner join lost_reason_labels lrl
        on lrl.lost_reason_id = dc.new_value::int
    where dc.field_key = 'lost_reason'
    group by dc.deal_id
),

-- Count how many distinct stages each deal actually passed through
stage_count as (
    select
        deal_id,
        count(distinct new_value::int)  as stages_touched,
        max(new_value::int)             as max_stage_reached_id
    from {{ ref('stg_deal_changes') }}
    where field_key = 'stage_id'
    group by deal_id
)

select
    dc.deal_id,
    dc.deal_created_at,

    ls.final_stage_id,
    st.stage_name                                           as final_stage_name,
    ls.final_stage_changed_at,

    le.lost_at,
    le.lost_reason_id,
    lrl.lost_reason_name,

    lo.owner_user_id,
    u.user_name                                             as owner_name,

    sc.stages_touched,
    sc.max_stage_reached_id,
    st_max.stage_name                                        as max_stage_reached_name,

    case when le.lost_at is not null then true else false end as is_lost,

    -- Full lost reason history as free text, chronological, separated by →
    -- e.g. "Customer Not Ready → Pricing Issues" for a deal lost twice
    -- Equals lost_reason_name when lost only once; null when never lost
    alr.all_lost_reasons_history,

    -- Days from creation to loss (or to end of data horizon if still active)
    coalesce(
        le.lost_at::date - dc.deal_created_at::date,
        (select max(changed_at)::date from {{ ref('stg_deal_changes') }}) - dc.deal_created_at::date
    )                                                       as days_in_pipeline

from deal_created dc
left join last_stage      ls using (deal_id)
left join lost_events     le using (deal_id)
left join last_owner      lo using (deal_id)
left join stage_count     sc using (deal_id)
left join {{ ref('stg_stages') }} st
    on st.stage_id = ls.final_stage_id
left join {{ ref('stg_stages') }} st_max
    on st_max.stage_id = sc.max_stage_reached_id
left join {{ ref('stg_users') }} u
    on u.user_id = lo.owner_user_id
left join lost_reason_labels lrl
    on lrl.lost_reason_id = le.lost_reason_id
left join all_lost_reasons alr
    on alr.deal_id = dc.deal_id
