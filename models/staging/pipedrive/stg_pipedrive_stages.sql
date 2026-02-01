with source as (
    select * 
    from {{ source('postgres_public','stages') }}
)
select stage_id,
       stage_name
from source 
