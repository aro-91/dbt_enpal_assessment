with source as (

    select * from "postgres"."public"."activity"

),

renamed as (

    select
    
        activity_id::integer as activity_id,
        deal_id::integer as deal_id,
        assigned_to_user::integer as user_id,
        type::varchar(50) as activity_type, 
        done::boolean as is_done,
        due_to as due_to
   
    from source

)

select * from renamed