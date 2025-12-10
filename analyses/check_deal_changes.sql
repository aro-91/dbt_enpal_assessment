-- Investigate the 'deal_changes' table to see what fields are being tracked.

select 
    changed_field_key,
    count(*) as frequency,
    min(change_time) as first_occurrence,
    max(change_time) as last_occurrence
from {{ source('postgres_public', 'deal_changes') }}
group by 1
order by 2 desc