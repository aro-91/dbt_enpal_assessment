with stage_field as (
  select field_value_options
  from {{ source('postgres_public','fields') }}
  where field_key = 'stage_id'
),

allowed_stage_ids as (
  select (opt->>'id')::int as stage_id
  from stage_field,
  lateral jsonb_array_elements(field_value_options::jsonb) as opt
),

stage_changes as (
  select new_value::int as stage_id
  from {{ ref('stg_pipedrive_deal_changes') }}
  where changed_field_key = 'stage_id'
    and new_value is not null
)

select sc.stage_id
from stage_changes sc
left join allowed_stage_ids a
  on sc.stage_id = a.stage_id
where a.stage_id is null
