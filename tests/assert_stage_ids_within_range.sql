/*
    Test: all stage_id values in deal_changes are within the known range (1–9)

    Why this matters:
    The stages table defines exactly 9 stages. If deal_changes contains a
    stage_id outside that range it means either:
      a) A new stage was added to Pipedrive but not to our stages seed/table
      b) Data corruption or a mismatched field key

    Either way the deal would fail to join to stg_stages and appear with
    a null stage_name throughout all reporting models — silently.

    Expected result: 0 rows.
*/

select
    deal_id,
    changed_at,
    new_value as invalid_stage_id
from {{ ref('stg_deal_changes') }}
where field_key = 'stage_id'
  and (
      new_value::int < 1
      or new_value::int > 9
  )
