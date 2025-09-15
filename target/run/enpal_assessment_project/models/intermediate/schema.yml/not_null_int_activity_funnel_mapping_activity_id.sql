
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select activity_id
from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
where activity_id is null



  
  
      
    ) dbt_internal_test