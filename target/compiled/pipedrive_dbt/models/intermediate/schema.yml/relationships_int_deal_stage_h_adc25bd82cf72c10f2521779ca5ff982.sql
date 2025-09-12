
    
    

with child as (
    select stage_id as from_field
    from pipedrive_analytics.intermediate.int_deal_stage_history
    where stage_id is not null
),

parent as (
    select stage_id as to_field
    from pipedrive_analytics.staging.stg_stages
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


