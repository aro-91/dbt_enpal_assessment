{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

with deal_stages as (
    select
        deal_id,
        new_value::number as stage_id,
        change_timestamp
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'stage_id'
    {% if is_incremental() %}
    and change_timestamp > (select coalesce(max(valid_from), '2024-01-01'::timestamp) from {{ this }})
    {% endif %} 
),
stages as (
    select
        stage_id,
        initcap(stage_name) as stage_name
    from {{ ref('stg_stages') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['deal_id', 'change_timestamp']) }} as deal_stage_change_id,
    deal_id,
    ds.stage_id,
    s.stage_name,
    change_timestamp as valid_from,
    lead(change_timestamp, 1) over (partition by deal_id order by change_timestamp) as valid_to
from deal_stages ds
left join stages s 
on ds.stage_id = s.stage_id