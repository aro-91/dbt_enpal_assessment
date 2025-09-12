
    
    

with child as (
    select deal_stage_change_id as from_field
    from pipedrive_analytics.intermediate.int_deals_with_kpis
    where deal_stage_change_id is not null
),

parent as (
    select deal_stage_change_id as to_field
    from pipedrive_analytics.intermediate.int_deal_stage_history
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


