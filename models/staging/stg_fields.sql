select
    id::bigint as field_id,
    field_key::text as field_key,
    name::text as field_name,
    field_value_options::jsonb as field_value_options
from {{ source('pipedrive', 'fields') }}
