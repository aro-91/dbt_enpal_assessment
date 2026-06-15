/*
    About half of each activity type has done = false (scheduled, not finished).
    That's why the Sales Call 1/2 counts in int_deal_sales_call (steps 2.1/3.1)
    only keep rows where is_done is true. NOTES.md (Section 4b) explains why,
    using how Pipedrive itself counts completed activities.
*/
select
    type as activity_type_code
    , done as is_done
    , count(*) as activity_count
from {{ source('pipedrive', 'activity') }}
group by 1, 2
order by 1, 2
