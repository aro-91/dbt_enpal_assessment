
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select active
from "postgres"."pipedrive_analytics"."raw_dim_activity_types"
where active is null



  
  
      
    ) dbt_internal_test