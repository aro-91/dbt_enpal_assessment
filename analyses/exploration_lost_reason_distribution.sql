/*
    Two things here:
    1. lost_reason is filled in for nearly every deal, spread evenly across 5
       reason codes (about 380 to 425 deals each). That even spread looks like
       filler data, not a real "this deal was lost" signal, so we treat it as
       just an attribute and don't use it to drop deals from
       rep_sales_funnel_monthly (see NOTES.md, Section 2).
    2. 5 deals have a second lost_reason (and add_time) row, which is why
       deal_changes shows 2,000 lost_reason/add_time rows for 1,995 deals. The
       funnel model doesn't use these, so it makes no difference to the report.
*/
select
    new_value as lost_reason
    , count(*) as deal_count
from {{ source('pipedrive', 'deal_changes') }}
where changed_field_key = 'lost_reason'
group by 1
order by 2 desc
