with source as (
    select * 
    from {{ source('postgres_public','activity') }}
)
select 
       activity_id,
       deal_id,
       done as is_done,
       type as task_type,
       due_to as due_to_at
from source
where done = true
