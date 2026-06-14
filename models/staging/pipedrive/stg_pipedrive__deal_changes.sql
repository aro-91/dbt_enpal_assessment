with source as (
    select * from {{ source('pipedrive', 'deal_changes') }}
)

, final as (
    select
        -- ids
        deal_id

        -- dimensions
        , changed_field_key
        , new_value

        -- date/times
        , change_time as changed_at
    from source
)

select * from final
