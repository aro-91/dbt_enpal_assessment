
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

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



  
  
      
    ) dbt_internal_test