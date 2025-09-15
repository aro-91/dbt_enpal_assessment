
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select month_year
from "postgres"."pipedrive_analytics"."int_activity_deals_funnel"
where month_year is null



  
  
      
    ) dbt_internal_test