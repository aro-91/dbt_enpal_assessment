
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deal_stage_change_id
from pipedrive_analytics.intermediate.int_deals_with_kpis
where deal_stage_change_id is null



  
  
      
    ) dbt_internal_test