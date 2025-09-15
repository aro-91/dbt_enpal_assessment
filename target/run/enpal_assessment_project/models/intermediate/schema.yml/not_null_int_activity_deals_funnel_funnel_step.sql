
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select funnel_step
from "postgres"."pipedrive_analytics"."int_activity_deals_funnel"
where funnel_step is null



  
  
      
    ) dbt_internal_test