
    
    

with all_values as (

    select
        type as value_field,
        count(*) as n_records

    from "postgres"."public_staging"."stg_activity_types"
    group by type

)

select *
from all_values
where value_field not in (
    'meeting','sc2','follow_up','after_close_call'
)


