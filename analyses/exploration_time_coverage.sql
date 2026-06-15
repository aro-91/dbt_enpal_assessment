/*
    Checks the date range of each source that feeds the funnel. Stage changes
    run from 2024-01 to 2025-02, but activities (where the Sales Call steps come
    from) stop at 2024-09-13. So in the monthly report, months after September
    2024 have stage steps but no Sales Call rows. It makes sense once you know
    it; it just means the 2.1/3.1 rows don't run as far out as the stage rows.
    See NOTES.md (Section 2).
*/
select
    'deal_changes.stage_id' as source_field
    , min(change_time)::date as earliest
    , max(change_time)::date as latest
from {{ source('pipedrive', 'deal_changes') }}
where changed_field_key = 'stage_id'

union all

select
    'activity.due_to (completed)' as source_field
    , min(due_to)::date as earliest
    , max(due_to)::date as latest
from {{ source('pipedrive', 'activity') }}
where done is true
