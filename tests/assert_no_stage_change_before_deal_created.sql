/*
    Test: no stage or user change event precedes the deal's add_time event

    Why this matters:
    The add_time event is our anchor for when a deal entered the system.
    If stage or user events appear before add_time, it suggests either:
      a) Clock skew / timezone issues in the source data
      b) Backfilled or synthetic records
      c) Events captured out of order by the Pipedrive API

    This would corrupt the date_spine cross-join (deals would appear in months
    before they existed) and misrepresent pipeline longevity metrics.

    Expected result: 0 rows.
*/

with deal_created as (
    select
        deal_id,
        min(changed_at) as deal_created_at
    from {{ ref('stg_deal_changes') }}
    where field_key = 'add_time'
    group by deal_id
)

select
    dc_events.deal_id,
    dc_events.field_key,
    dc_events.changed_at       as event_time,
    dc.deal_created_at
from {{ ref('stg_deal_changes') }} dc_events
inner join deal_created dc
    on dc.deal_id = dc_events.deal_id
where dc_events.field_key in ('stage_id', 'user_id', 'lost_reason')
  and dc_events.changed_at < dc.deal_created_at
