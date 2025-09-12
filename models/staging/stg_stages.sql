with source as (
    select * from {{ source('raw', 'stages') }}
),
renamed as (
    select
        stage_id::number as stage_id,
        stage_name
    from source
)
select * from renamed