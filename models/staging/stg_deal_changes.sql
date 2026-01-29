with src as (
    select
        deal_id::bigint as deal_id,
        change_time::timestamp as changed_at,
        changed_field_key::text as changed_field_key,
        new_value::text as new_value,
        row_number() over (
            partition by
                deal_id::bigint,
                change_time::timestamp,
                changed_field_key::text,
                new_value::text
            order by change_time
        ) as rn
    from {{ source('pipedrive', 'deal_changes') }}
),

deduped as (
    select
        deal_id,
        changed_at,
        changed_field_key,
        new_value
    from src
    where rn = 1
)

select
    deal_id,
    changed_at,
    changed_field_key,
    new_value
from deduped
