
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select stage_name
from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
where stage_name is null



  
  
      
    ) dbt_internal_test