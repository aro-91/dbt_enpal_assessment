
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select due_month_year
from "postgres"."pipedrive_analytics"."raw_fact_activities"
where due_month_year is null



  
  
      
    ) dbt_internal_test