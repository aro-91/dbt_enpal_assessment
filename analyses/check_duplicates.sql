-- Check for duplicates in the primary activity table

select 
    activity_id,
    count(*)
from {{ source('postgres_public', 'activity') }}
group by 1
having count(*) > 1