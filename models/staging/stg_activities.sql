with source as (
    select * from {{ source('postgres_public', 'activity') }}
),

staged as (
    select
        activity_id,
        type as activity_type,
        assigned_to_user as user_id,
        deal_id,
        done as is_done,
        due_to as activity_timestamp
    from source
)

select * from staged

