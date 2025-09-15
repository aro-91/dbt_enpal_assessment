
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_time
from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
where change_time is null



  
  
      
    ) dbt_internal_test