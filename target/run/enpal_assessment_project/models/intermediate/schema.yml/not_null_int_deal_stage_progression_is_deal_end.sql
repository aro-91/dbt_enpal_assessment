
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_deal_end
from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
where is_deal_end is null



  
  
      
    ) dbt_internal_test