with src as (
    select
        id::bigint as activity_type_id,
        name::text as activity_type_name,
        type::text as activity_type_key,
        case
            when lower(active::text) in ('yes', 'y', 'true', 't', '1') then true
            when lower(active::text) in ('no', 'n', 'false', 'f', '0') then false
            else null
        end as is_active
    from {{ source('pipedrive', 'activity_types') }}
)

select
    activity_type_id,
    activity_type_name,
    activity_type_key,
    is_active
from src
