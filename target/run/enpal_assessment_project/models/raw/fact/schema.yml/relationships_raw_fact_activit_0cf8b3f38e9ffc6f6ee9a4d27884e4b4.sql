
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select type as from_field
    from "postgres"."pipedrive_analytics"."raw_fact_activities"
    where type is not null
),

parent as (
    select type as to_field
    from "postgres"."pipedrive_analytics"."raw_dim_activity_types"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test