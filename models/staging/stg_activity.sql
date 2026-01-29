/*
NOTE:
The raw Pipedrive activity_id is not unique in this dataset (the same `activity_id` can appear
across multiple records with different attributes). To provide a stable unique identifier at
the staging grain, this model deduplicates exact duplicate rows and introduces `activity_sk` as
a surrogate key derived from the staged activity attributes.
*/

with src as (
    select
        activity_id::bigint as activity_id,
        type::text as activity_type_key,
        assigned_to_user::bigint as assigned_to_user_id,
        deal_id::bigint as deal_id,
        done::boolean as is_done,
        due_to::timestamp as due_at,
        row_number() over (
            partition by
                activity_id::bigint,
                deal_id::bigint,
                type::text,
                due_to::timestamp,
                assigned_to_user::bigint,
                done::boolean
            order by activity_id
        ) as rn
    from {{ source('pipedrive', 'activity') }}
),

deduped as (
    select
        activity_id,
        activity_type_key,
        assigned_to_user_id,
        deal_id,
        is_done,
        due_at
    from src
    where rn = 1
)

select
    md5(
        concat_ws(
            '|',
            activity_id,
            deal_id,
            activity_type_key,
            due_at,
            assigned_to_user_id,
            is_done
        )
    ) as activity_sk,
    activity_id,
    activity_type_key,
    assigned_to_user_id,
    deal_id,
    is_done,
    due_at
from deduped
