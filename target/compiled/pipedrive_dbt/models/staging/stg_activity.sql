
-- could potentially add on_schema_change to the config
-- but i'd prefer stricter control until contracts are in place

with source as (
    select
        activity_id,
        type as activity_type,
        assigned_to_user as assigned_to_user_id,
        deal_id,
        done::boolean as is_done,
        due_to::timestamp as due_to_timestamp
    from pipedrive_analytics.raw.activity
    
    where due_to > (select coalesce(max(due_to_timestamp), '2024-01-01'::timestamp) from pipedrive_analytics.staging.stg_activity)
     
),
deduped as (
    select *,
               row_number() over (
                   partition by activity_id
                   order by due_to_timestamp desc
               ) as rn
        from source  
)
select * from deduped
where rn = 1