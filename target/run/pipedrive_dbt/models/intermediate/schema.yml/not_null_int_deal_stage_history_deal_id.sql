
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deal_id
from pipedrive_analytics.intermediate.int_deal_stage_history
where deal_id is null



  
  
      
    ) dbt_internal_test