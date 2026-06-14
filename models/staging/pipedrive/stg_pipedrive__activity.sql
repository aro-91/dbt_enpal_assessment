with source as (
    select * from {{ source('pipedrive', 'activity') }}
)

, final as (
    select
        -- ids
        activity_id
        , deal_id
        , assigned_to_user as assigned_to_user_id

        -- dimensions
        , type as activity_type_code
        , done as is_done

        -- date/times
        , due_to as due_at
    from source
)

select * from final
