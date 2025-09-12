

with deal_stages as (
    select
        deal_id,
        new_value::number as stage_id,
        change_timestamp
    from pipedrive_analytics.staging.stg_deal_changes
    where changed_field_key = 'stage_id'
    
    and change_timestamp > (select coalesce(max(valid_from), '2024-01-01'::timestamp) from pipedrive_analytics.intermediate.int_deal_stage_history)
     
),
stages as (
    select
        stage_id,
        initcap(stage_name) as stage_name
    from pipedrive_analytics.staging.stg_stages
)
select
    md5(cast(coalesce(cast(deal_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(change_timestamp as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as deal_stage_change_id,
    deal_id,
    ds.stage_id,
    s.stage_name,
    change_timestamp as valid_from,
    lead(change_timestamp, 1) over (partition by deal_id order by change_timestamp) as valid_to
from deal_stages ds
left join stages s 
on ds.stage_id = s.stage_id