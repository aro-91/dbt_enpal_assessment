with activity as (

    select * from {{ source('pipedrive', 'activity') }}

),

renamed as (

    select
        activity_id
        , deal_id
        , type                       as activity_type_code
        , assigned_to_user           as assigned_to_user_id
        , done                       as is_done
        , due_to::timestamp          as due_at

    from activity

)

select * from renamed
