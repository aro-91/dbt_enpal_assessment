
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        funnel_sub_step as value_field,
        count(*) as n_records

    from pipedrive_analytics.intermediate.int_deals_with_kpis
    group by funnel_sub_step

)

select *
from all_values
where value_field not in (
    'Step 2.1: Sales Call 1','Step 3.1: Sales Call 2'
)



  
  
      
    ) dbt_internal_test