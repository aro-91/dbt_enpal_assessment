

with source as (
    select
        deal_id,
        change_time::timestamp as change_timestamp,
        changed_field_key,
        new_value::string as new_value
    from pipedrive_analytics.raw.deal_changes
    
    where change_time > (select coalesce(max(change_timestamp), '2024-01-01'::timestamp) from pipedrive_analytics.staging.stg_deal_changes)
    
)
select * from source