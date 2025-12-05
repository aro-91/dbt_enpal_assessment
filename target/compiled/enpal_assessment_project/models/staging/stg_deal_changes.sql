with source as (

    select * from "postgres"."public"."deal_changes"

),

renamed as (

    select

        deal_id::integer as deal_id,
        change_time as changed_at,
        changed_field_key as changed_field,
        
        
        case 
            when changed_field_key = 'stage_id' AND new_value ~ '^[0-9]+$' 
            then new_value::integer 
            else NULL 
        end as new_stage_id,
        
        case 
            when changed_field_key = 'user_id' AND new_value ~ '^[0-9]+$' 
            then new_value::integer 
            else NULL 
        end as new_user_id,
        
        case 
            when changed_field_key = 'add_time' 
            then 
                new_value::timestamp 
            else NULL 
        end as new_add_time,
        
        case 
            when changed_field_key = 'lost_reason' 
            then new_value::varchar(255) 
            else NULL 
        end as new_lost_reason_value

    from source
    where changed_field_key in ('stage_id', 'user_id', 'add_time', 'lost_reason')

)

select * from renamed