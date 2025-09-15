
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select id
from "postgres"."pipedrive_analytics"."raw_dim_activity_types"
where id is null



  
  
      
    ) dbt_internal_test