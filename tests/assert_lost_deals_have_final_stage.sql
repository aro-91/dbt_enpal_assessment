/*
    Test: every deal marked as lost has a final_stage_id recorded

    Why this matters:
    A lost deal with no stage would mean the deal was closed without ever
    being assigned to the funnel — either a data quality issue at source
    (e.g., deal added and immediately marked lost with no stage transition),
    or a gap in our EAV parsing logic.

    These deals would be invisible in rep_stage_funnel_analysis (stage = null)
    and would silently skew drop-off rates.

    Expected result: 0 rows.
    If rows are returned, investigate whether source has deals lost before
    any stage_id change was recorded (e.g., duplicates or API errors).
*/

select
    deal_id,
    lost_at,
    lost_reason_name
from {{ ref('int_deal_summary') }}
where is_lost = true
  and final_stage_id is null
