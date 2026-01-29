select
    id::bigint as user_id,
    name::text as user_name,
    email::text as user_email,
    modified::timestamp as modified_at
from {{ source('pipedrive', 'users') }}
