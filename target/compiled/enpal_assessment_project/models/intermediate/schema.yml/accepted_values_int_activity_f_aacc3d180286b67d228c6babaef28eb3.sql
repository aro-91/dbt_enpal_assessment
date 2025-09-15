
    
    

with all_values as (

    select
        activity_type as value_field,
        count(*) as n_records

    from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
    group by activity_type

)

select *
from all_values
where value_field not in (
    'follow_up','after_close_call','sc_2','meeting'
)


