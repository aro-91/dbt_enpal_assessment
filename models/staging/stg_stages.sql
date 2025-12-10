with source as (
    select * from {{ source('postgres_public', 'stages') }}
),

staged as (
    select
        stage_id,
        stage_name
    from source
)

select * from staged

