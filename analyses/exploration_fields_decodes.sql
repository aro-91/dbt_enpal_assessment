/*
    The fields table is just a lookup for the codes used in deal_changes. It
    holds 4 fields (add_time = "Deal created", user_id = "Owner", stage_id =
    "Stage", lost_reason = "Lost reason") and the labels behind the numeric
    codes:
    - stage_id: 1 = Lead Generation ... 9 = Renewal/Expansion. These match the
      stages table, but the labels here are title-case (e.g. "Qualified Lead")
      while the stages table stores "Qualified lead". The report uses the stages
      table (see NOTES.md Section 4d).
    - lost_reason: 1 = Customer Not Ready, 2 = Pricing Issues, 3 = Unreachable
      Customer, 4 = Product Mismatch, 5 = Duplicate Entry. The funnel doesn't use
      lost_reason (see NOTES.md Section 2), but this is what the codes mean.
*/
select
    field_key
    , name
    , field_value_options
from {{ source('pipedrive', 'fields') }}
order by field_key
