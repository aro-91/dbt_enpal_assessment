with fields as (

    select * from {{ source('pipedrive', 'fields') }}

),

renamed as (

    select
        id                           as field_id
        , field_key
        , name                       as field_name
        , field_value_options

    from fields

)

select * from renamed
