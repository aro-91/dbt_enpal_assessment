{{
    config(materialized='view')
}}

/*
    stg_fields
    ──────────
    Unpacks the JSONB field_value_options array from the fields source table
    into one row per (field_key, option_id, option_label).

    This replaces hardcoded CASE statements across the project.
    Any change to Pipedrive enum labels (e.g. a lost_reason is renamed)
    is automatically reflected everywhere by re-running dbt — no model edits needed.

    Downstream usage:
      - Filter WHERE field_key = 'lost_reason' to get lost reason labels
      - Filter WHERE field_key = 'stage_id'    to get stage labels
        (cross-check against stg_stages via assert_stages_match_field_options test)
*/

with source as (
    select * from {{ source('pipedrive', 'fields') }}
),

unpacked as (
    select
        lower(field_key)                as field_key,
        (elem ->> 'id')::int            as option_id,
        elem ->> 'label'                as option_label
    from source
    cross join lateral jsonb_array_elements(field_value_options) as elem
    where field_value_options is not null
)

select
    field_key,
    option_id,
    option_label
from unpacked
