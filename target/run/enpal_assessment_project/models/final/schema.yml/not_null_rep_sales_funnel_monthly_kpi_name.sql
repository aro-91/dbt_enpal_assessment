
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select kpi_name
from "postgres"."pipedrive_analytics"."rep_sales_funnel_monthly"
where kpi_name is null



  
  
      
    ) dbt_internal_test