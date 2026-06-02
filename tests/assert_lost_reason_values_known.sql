/*
    Test: all lost_reason values in deal_changes are within the known set (1–5)

    Why this matters:
    Lost reason codes are decoded inline via a CASE statement in multiple models.
    If a new reason code is added to Pipedrive (e.g., id=6 "Competitor") but
    not to our CASE expressions, it would silently produce a null lost_reason_name
    across all reporting — without any error or warning.

    This test surfaces unknown codes immediately so the CASE statements can be
    updated before data reaches BI consumers.

    Known codes (from fields.csv FIELD_VALUE_OPTIONS):
      1 = Customer Not Ready
      2 = Pricing Issues
      3 = Unreachable Customer
      4 = Product Mismatch
      5 = Duplicate Entry

    Expected result: 0 rows.
*/

select
    deal_id,
    changed_at,
    new_value as unknown_lost_reason_id
from {{ ref('stg_deal_changes') }}
where field_key = 'lost_reason'
  and new_value::int not in (1, 2, 3, 4, 5)
