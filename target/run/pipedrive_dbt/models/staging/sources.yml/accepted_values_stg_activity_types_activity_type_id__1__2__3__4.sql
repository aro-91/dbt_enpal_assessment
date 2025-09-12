
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        activity_type_id as value_field,
        count(*) as n_records

    from pipedrive_analytics.staging.stg_activity_types
    group by activity_type_id

)

select *
from all_values
where value_field not in (
    '1','2','3','4'
)



  
  
      
    ) dbt_internal_test