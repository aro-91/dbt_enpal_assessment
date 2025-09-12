
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    the_date as unique_field,
    count(*) as n_records

from pipedrive_analytics.intermediate.int_dim_date
where the_date is not null
group by the_date
having count(*) > 1



  
  
      
    ) dbt_internal_test