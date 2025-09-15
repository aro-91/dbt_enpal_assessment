
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_month
from "postgres"."pipedrive_analytics"."raw_fact_deal_changes"
where change_month is null



  
  
      
    ) dbt_internal_test