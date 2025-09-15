
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        stage_id as value_field,
        count(*) as n_records

    from "postgres"."pipedrive_analytics"."raw_dim_stages"
    group by stage_id

)

select *
from all_values
where value_field not in (
    '1','2','3','4','5','6','7','8','9'
)



  
  
      
    ) dbt_internal_test