
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select activity_status
from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
where activity_status is null



  
  
      
    ) dbt_internal_test