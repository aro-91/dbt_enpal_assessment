/*
    Test: stage IDs in stg_stages match stage IDs in stg_fields (field_value_options)

    Why this matters:
    The project has two independent sources of truth for stages:
      1. The `stages` table — a flat lookup used for joins
      2. The `fields` table — a JSONB enum definition used for label resolution

    Both are maintained separately in Pipedrive and exported independently.
    If a new stage is added on the Pipedrive side:
      - It may appear in fields.field_value_options but not yet in stages
      - It may appear in stages but its label may differ from field_value_options
    Either mismatch causes silent null stage_names or inconsistent labels in reporting.

    This test surfaces any divergence immediately so it can be resolved at source
    before it affects dashboards.

    Expected result: 0 rows.
*/

with stage_ids_from_stages as (
    select stage_id::text as id_value
    from {{ ref('stg_stages') }}
),

stage_ids_from_fields as (
    select option_id::text as id_value
    from {{ ref('stg_fields') }}
    where field_key = 'stage_id'
),

in_stages_not_fields as (
    select
        id_value,
        'Stage ID exists in stages table but is missing from fields.field_value_options' as discrepancy
    from stage_ids_from_stages
    where id_value not in (select id_value from stage_ids_from_fields)
),

in_fields_not_stages as (
    select
        id_value,
        'Stage ID exists in fields.field_value_options but is missing from stages table' as discrepancy
    from stage_ids_from_fields
    where id_value not in (select id_value from stage_ids_from_stages)
)

select * from in_stages_not_fields
union all
select * from in_fields_not_stages
