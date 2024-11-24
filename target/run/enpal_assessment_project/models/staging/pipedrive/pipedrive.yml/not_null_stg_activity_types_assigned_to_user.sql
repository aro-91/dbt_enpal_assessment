select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select assigned_to_user
from "postgres"."public_staging"."stg_activity_types"
where assigned_to_user is null



      
    ) dbt_internal_test