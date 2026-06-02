{{
    config(materialized='view')
}}

with source as (
    select * from {{ source('pipedrive', 'activity') }}
),

-- SOURCE DATA QUALITY: activity_id is not unique in the raw table.
-- Duplicates appear to be exact row-level copies (same all fields).
-- We keep the first occurrence per activity_id to enforce the expected grain.
-- Document this finding: activity data may have been exported with duplicates
-- or re-ingested without deduplication at the pipeline layer.
deduped as (
    select distinct on (activity_id)
        activity_id,
        type,
        assigned_to_user,
        deal_id,
        done,
        due_to
    from source
    order by activity_id
)

select
    activity_id,
    type              as activity_type,
    assigned_to_user  as user_id,
    deal_id,
    done,
    due_to::timestamp as due_at
from deduped
