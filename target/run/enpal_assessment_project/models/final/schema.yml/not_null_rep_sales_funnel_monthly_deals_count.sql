
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deals_count
from "postgres"."pipedrive_analytics"."rep_sales_funnel_monthly"
where deals_count is null



  
  
      
    ) dbt_internal_test