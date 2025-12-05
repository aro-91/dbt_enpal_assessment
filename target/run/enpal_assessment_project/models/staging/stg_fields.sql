
  
    

  create  table "postgres"."public_public"."stg_fields__dbt_tmp"
  
  
    as
  
  (
    with source as (

    select * from "postgres"."public"."fields"

),

-- Unnesting  JSON (stage_id ve lost_reason)
unnested_options as (
    select
        id as field_id,
        field_key,
        name as field_name,
        field_value_options,
        -- Unnest the JSONB array into rows, no rows if JSONB is NULL.
        jsonb_array_elements(field_value_options) as value_option
    from source
),

final_mapping as (

    select

        field_id::integer as field_id,
        field_key::varchar(50) as field_key,
        field_name::varchar(255) as field_name,
        case 
            when field_value_options is not null 
            then (value_option ->> 'id')::integer
            else NULL 
        end as field_value_id,
        case 
            when field_value_options is not null 
            then (value_option ->> 'label')::varchar(255)
            else NULL 
        end as field_value_label

    from unnested_options

)

select * from final_mapping
  );
  