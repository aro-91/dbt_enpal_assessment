
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_completed
from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
where is_completed is null



  
  
      
    ) dbt_internal_test