with source as (
    select * from {{ source('pipedrive', 'stages') }}
)

, final as (
    select
        -- ids
        stage_id

        -- dimensions
        , stage_name
    from source
)

select * from final
