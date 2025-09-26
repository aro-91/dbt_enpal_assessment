{{ config(materialized='view',
    schema='public_pipedrive_analytics') }}

with src as (
  select
    deal_changes.deal_id,
    stages.stage_id,
    stages.stage_name,
    deal_changes.changed_at
  from {{ ref('stg_pipedrive_deal_changes') }} as deal_changes
  inner join {{ ref('stg_pipedrive_stages') }} as stages
  on deal_changes.new_value::bigint = stages.stage_id
  where changed_field_key = 'stage_id'
)
select * from src