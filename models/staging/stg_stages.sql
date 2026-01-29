select
    stage_id::bigint as stage_id,
    stage_name::text as stage_name
from {{ source('pipedrive', 'stages') }}
