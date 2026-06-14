/*
    Exploratory query: confirms that a deal's stage_id history is not
    monotonic - deals can skip stages (e.g. 5 -> 8) or revisit earlier ones
    (e.g. 8 -> 1). 2,510 of the 8,906 stage_id changes are such "non-step"
    transitions.

    This is why int_deal_stage_history uses "first time reached"
    (min(changed_at) per deal_id + stage_id) rather than "latest stage" or
    "every transition" - it's robust to this skip/revisit behavior and gives
    a clean monthly milestone view.
*/
with stage_changes as (
    select
        deal_id
        , cast(new_value as integer) as stage_id
        , change_time
        , lag(cast(new_value as integer)) over (
            partition by deal_id order by change_time
        ) as previous_stage_id
    from {{ source('pipedrive', 'deal_changes') }}
    where changed_field_key = 'stage_id'
)

select
    deal_id
    , previous_stage_id
    , stage_id
    , change_time
from stage_changes
where previous_stage_id is not null
    and (stage_id < previous_stage_id or stage_id > previous_stage_id + 1)
order by 1, 4
