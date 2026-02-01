with source as (
    select * 
    from {{ source('postgres_public','deal_changes') }}
)
select deal_id,
       changed_field_key,
       new_value, 
       change_time as stage_entered_at
from source 
