{{ 
config(
    materialized='incremental',
    unique_key=['deal_id', 'stage_start_time', 'changed_field_key'],
    incremental_strategy='merge'
) 
}}

{% set threshold_days = 3 %}  -- must be adjusted according to business pace and needs

-- I need business input to understand changing user_ids in same deal_ids are a data quality issue or part of business
-- I assumed it is part of the business, therefore I aimed to bring as is user_id for each stage in given stage.

with cte_impacted_deals as (
    select distinct deal_id
    from {{ ref('stg_deal_changes') }}
    {% if is_incremental() %}
    where changed_at >= current_date - interval '{{ threshold_days }} day'
    {% endif %}
)


, cte_user_changes as (
    select
        deal_id,
        changed_at as valid_from,
        new_value::int as user_id,
        coalesce(lead(changed_at) over (
            partition by deal_id
            order by changed_at
        ), timestamp '2999-12-31 23:59:59') as valid_to
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'user_id'
    {% if is_incremental() %}
        and deal_id in (select deal_id from cte_impacted_deals)
    {% endif %} 
)


, cte_deal_changes as (
    select
        deal_id,
        changed_at as stage_start_time,
        new_value::int as stage_id,
        changed_field_key,
        lead(changed_at) over (partition by deal_id order by changed_at) as stage_end_time
    from {{ ref('stg_deal_changes') }}
    where
        changed_field_key in ('stage_id', 'lost_reason')
        -- process only recent activities to reduce volume
    {% if is_incremental() %}
        and deal_id in (select deal_id from cte_impacted_deals)
    {% endif %} 
)

select
    cte_deal_changes.deal_id,
    user_id, -- useful for any location/team/marketing etc. related analyses
    cte_deal_changes.changed_field_key as changed_field_key, -- just bringing to keep incremental logic work
    cte_deal_changes.stage_id,
    case when cte_deal_changes.changed_field_key = 'lost_reason' then concat('Lost - ', field_options.label_value)
         else label_value end as stage_name, -- includes lost deals for future analyses
    case when cte_deal_changes.changed_field_key = 'lost_reason' then true 
         else false end as is_lost_deal,
    cte_deal_changes.stage_start_time,
    cte_deal_changes.stage_end_time,
    cte_deal_changes.stage_end_time::date - cte_deal_changes.stage_start_time::date as stage_duration_in_days -- useful for any funnel analyses and continuous improvement works
from cte_deal_changes
left join cte_user_changes
  on cte_deal_changes.deal_id = cte_user_changes.deal_id
     and cte_deal_changes.stage_start_time >= cte_user_changes.valid_from
     and cte_deal_changes.stage_start_time < cte_user_changes.valid_to
     and (cte_deal_changes.stage_end_time >= cte_user_changes.valid_from or cte_deal_changes.stage_end_time is null)
left join {{ ref('int_field_options') }} as field_options
    on cte_deal_changes.changed_field_key = field_options.field_key
        and cte_deal_changes.stage_id = field_options.label_id
