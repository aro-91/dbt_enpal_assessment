
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_month_year
from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
where change_month_year is null



  
  
      
    ) dbt_internal_test