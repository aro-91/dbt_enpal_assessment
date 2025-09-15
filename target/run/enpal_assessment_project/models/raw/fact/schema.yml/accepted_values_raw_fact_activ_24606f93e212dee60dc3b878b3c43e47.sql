
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        type as value_field,
        count(*) as n_records

    from "postgres"."pipedrive_analytics"."raw_fact_activities"
    group by type

)

select *
from all_values
where value_field not in (
    'follow_up','after_close_call','sc_2','meeting'
)



  
  
      
    ) dbt_internal_test