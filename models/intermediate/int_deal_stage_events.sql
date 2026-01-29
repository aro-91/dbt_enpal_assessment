with stage_changes as (
    select
        deal_id,
        changed_at as stage_entered_at,
        new_value::int as stage_id
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'stage_id'
),

final as (
    select
        stage_changes.deal_id,
        stage_changes.stage_id,
        stg_stages.stage_name,
        stage_changes.stage_entered_at,
        date_trunc('month', stage_changes.stage_entered_at)::date as stage_entered_month
    from stage_changes
    join {{ ref('stg_stages') }}
      on stage_changes.stage_id = stg_stages.stage_id
)

select
    deal_id,
    stage_id,
    stage_name,
    stage_entered_at,
    stage_entered_month
from final
