
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    deal_stage_change_id as unique_field,
    count(*) as n_records

from pipedrive_analytics.intermediate.int_deal_stage_history
where deal_stage_change_id is not null
group by deal_stage_change_id
having count(*) > 1



  
  
      
    ) dbt_internal_test