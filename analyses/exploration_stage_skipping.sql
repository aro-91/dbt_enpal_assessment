/*
    Shows that deals don't move through the stages in order: they jump forward
    (e.g. 5 to 8) or drop back (e.g. 8 to 1). 2,510 of the 8,906 stage changes
    are jumps like that (not a simple step up by one).

    This is why int_deal_stage_history counts a deal into a stage at the first
    time it reached that stage or later, instead of using its latest stage or
    counting every move. That approach copes with the jumps and gives a clean
    month-by-month view.
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
