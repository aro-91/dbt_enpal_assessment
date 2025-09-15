
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select new_stage_id
from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
where new_stage_id is null



  
  
      
    ) dbt_internal_test