-- This staging model cleans up the public.deal_changes table.
-- It focuses on changes that are relevant to the deal's funnel progression,
-- specifically when a 'stage_id' is changed.
-- It also renames columns for consistency.
SELECT
    deal_id,
    change_time,
    changed_field_key,
    new_value
FROM {{ source('raw', 'deal_changes') }}
