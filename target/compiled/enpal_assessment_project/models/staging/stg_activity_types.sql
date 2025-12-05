with source as (

    select * from "postgres"."public"."activity_types"

),

renamed as (

    select

        id::integer as activity_type_id,
        name::varchar(255) as activity_type_name,
        type::varchar(50) as type,
        case 
            when active = 'Yes' then TRUE 
            when active = 'No' then FALSE 
            else FALSE -- in case other input receives e.g. NULL, string 
        end as is_active
        
    from source

)

select * from renamed