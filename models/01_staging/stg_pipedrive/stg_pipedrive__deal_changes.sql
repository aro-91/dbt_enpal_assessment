with deal_changes as (

    select * from {{ source('pipedrive', 'deal_changes') }}

),

renamed as (

    select
        deal_id
        , change_time::timestamp     as changed_at
        , trim(lower(changed_field_key)) as changed_field_key
        , new_value

    from deal_changes

)

select * from renamed
