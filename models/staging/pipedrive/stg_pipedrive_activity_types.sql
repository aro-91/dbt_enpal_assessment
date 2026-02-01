with source as (
    select * 
    from {{ source('postgres_public','activity_types') }}
)
select 
       id as activity_type_id,
       name as activity_type_name,
       active::boolean as is_active,
       type as activity_type
from source 
