with source as (
    select * from {{ source('postgres_public', 'users') }}
),

staged as (
    select
        id as user_id,
        name as user_name,
        email as user_email,
        modified as user_modified_at
    from source
)

select * from staged
