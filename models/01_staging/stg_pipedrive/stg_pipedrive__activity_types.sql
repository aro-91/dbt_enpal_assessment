with activity_types as (

    select * from {{ source('pipedrive', 'activity_types') }}

),

renamed as (

    select
        id                           as activity_type_id
        , name                       as activity_type_name
        , type                       as activity_type_code
        , case
            when active = 'Yes' then true
            when active = 'No'  then false
          end                        as is_active

    from activity_types

)

select * from renamed
