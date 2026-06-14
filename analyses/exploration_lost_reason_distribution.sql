/*
    Exploratory query, two findings:
    1. lost_reason is populated for ~100% of deals, split roughly evenly
       across 5 reason codes (~380-425 deals each). This even distribution
       looks like synthetic fill rather than a genuine "deal lost" signal, so
       lost_reason is treated as deal metadata only and does not filter deals
       out of rep_sales_funnel_monthly (see NOTES.md, Section 3).
    2. 5 deals have a second lost_reason (and add_time) entry, which is why
       deal_changes has 2,000 lost_reason/add_time rows for 1,995 distinct
       deals. Not used by the funnel model, so this doesn't affect
       rep_sales_funnel_monthly.
*/
select
    new_value as lost_reason
    , count(*) as deal_count
from {{ source('pipedrive', 'deal_changes') }}
where changed_field_key = 'lost_reason'
group by 1
order by 2 desc
