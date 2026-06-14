/*
    Exploratory query: roughly half of each activity type is done = false
    (scheduled, not completed). This is why int_deal_sales_call's Sales Call
    1/2 counts (funnel steps 2.1/3.1) filter on is_done is true - see
    NOTES.md (Section 5b) for the Pipedrive-convention justification.
*/
select
    type as activity_type_code
    , done as is_done
    , count(*) as activity_count
from {{ source('pipedrive', 'activity') }}
group by 1, 2
order by 1, 2
