
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select the_date
from pipedrive_analytics.intermediate.int_dim_date
where the_date is null



  
  
      
    ) dbt_internal_test