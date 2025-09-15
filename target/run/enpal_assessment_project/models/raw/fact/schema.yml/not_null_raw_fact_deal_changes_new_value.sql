
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select new_value
from "postgres"."pipedrive_analytics"."raw_fact_deal_changes"
where new_value is null



  
  
      
    ) dbt_internal_test