{#
    Purpose: Converts the json array of stage_id options from the fields
    table into a clean stage funnel lookup.

    Grain: one row per stage_id.

    Note: jsonb_array_elements() is not available in Snowflake and would
    need to be converted when migrating -- see FLATTEN() instead.
#}

with stg_pipedrive__fields as (
    {# select all metadata from fields table #}

    select * from {{ ref('stg_pipedrive__fields') }}

),

stage_field as (
    {# filter to stage_id only #}

    select field_value_options
    from stg_pipedrive__fields
    where field_key = 'stage_id'

),

final as (
    {# unpack json array #}

    select
        (opt ->> 'id')::int    as stage_id
        , opt ->> 'label'      as kpi_name

    from stage_field
    cross join jsonb_array_elements(field_value_options) as opt

)

select * from final
