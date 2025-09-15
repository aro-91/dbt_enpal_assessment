
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select due_month
from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
where due_month is null



  
  
      
    ) dbt_internal_test