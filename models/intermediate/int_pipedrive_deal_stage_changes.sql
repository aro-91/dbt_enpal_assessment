with stage_changes as (

    select
        stg_pipedrive_deal_changes.deal_id,
        stg_pipedrive_deal_changes.new_value::int as stage_id,
        stg_pipedrive_stages.stage_name,
        stg_pipedrive_deal_changes.stage_entered_at::timestamp
    from {{ref ('stg_pipedrive_deal_changes')}} stg_pipedrive_deal_changes
    left join {{ref ('stg_pipedrive_stages')}} stg_pipedrive_stages
        on stg_pipedrive_deal_changes.new_value::int = stg_pipedrive_stages.stage_id
    where stg_pipedrive_deal_changes.changed_field_key = 'stage_id'

),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'deal_id',
            'stage_id',
            'stage_entered_at'
            ]) }} as deal_stage_event_id,
        deal_id,
        stage_id,
        stage_name,
        stage_entered_at,
        coalesce(
            lead(stage_entered_at) over (
                partition by deal_id
                order by stage_entered_at asc
            ),
            timestamp '9999-12-31'
        ) as stage_exited_at
    from stage_changes
)
select * 
from final 