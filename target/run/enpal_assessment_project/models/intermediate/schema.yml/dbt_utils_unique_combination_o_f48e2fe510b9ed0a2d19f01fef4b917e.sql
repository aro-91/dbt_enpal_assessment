
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        change_time, deal_id
    from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
    group by change_time, deal_id
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test