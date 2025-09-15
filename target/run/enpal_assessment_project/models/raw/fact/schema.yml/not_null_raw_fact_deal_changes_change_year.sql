
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_year
from "postgres"."pipedrive_analytics"."raw_fact_deal_changes"
where change_year is null



  
  
      
    ) dbt_internal_test