with source as (
    select * from {{ source('pipedrive', 'activity_types') }}
)

, final as (
    select
        -- ids
        id as activity_type_id
        , type as activity_type_code

        -- dimensions
        , name as activity_type_name
        , active = 'Yes' as is_active
    from source
)

select * from final
