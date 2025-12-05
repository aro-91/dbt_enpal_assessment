with changes as (
    select * from "postgres"."public_public"."stg_deal_changes"
),

-- Initial Metadata (created_at) and Last State Metadata (user_id, lost_reason)
metadata as (
    select
        deal_id,
        -- Get the original deal creation timestamp (add_time)
        max(case when changed_field = 'add_time' then new_add_time end) as created_at,
        
        -- Get the final closure timestamp (If the deal was marked as lost, we use the timestamp of that last lost_reason event)
        max(case when changed_field = 'lost_reason' then changed_at end) as closed_at,
        

        ((array_agg(new_user_id order by changed_at desc, changed_field desc) 
            filter (where new_user_id is not null))
        )[1] as final_user_id,


        ((array_agg(new_lost_reason_value order by changed_at desc, changed_field desc) 
            filter (where new_lost_reason_value is not null))
        )[1] as final_lost_reason_value

    from changes
    group by 1
),

final as (

    select

        deal_id,
        created_at,
        closed_at,
        final_user_id as owner_user_id,
        final_lost_reason_value as lost_reason_value,
        case 
            when final_lost_reason_value is not null then TRUE 
            else FALSE 
        end as is_lost
        
    from metadata

)

select * from final