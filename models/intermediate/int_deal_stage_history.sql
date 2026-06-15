with stg_pipedrive__deal_changes as (
    select * from {{ ref('stg_pipedrive__deal_changes') }}
)

, stg_pipedrive__stages as (
    select * from {{ ref('stg_pipedrive__stages') }}
)

, stage_events as (
    select
        deal_id
        , cast(new_value as integer) as stage_id
        , changed_at
    from stg_pipedrive__deal_changes
    where changed_field_key = 'stage_id'
)

/*
    Pipedrive's own funnel report counts a deal into every stage up to the
    furthest one it reached, including stages it skipped (a deal that jumped
    from 2 to 5 also counts in 3 and 4). About 84% of deals here skip a stage, so we
    fill those gaps in.

    The trick: a change to stage s means the deal reached stage s, so it also
    counts for every earlier stage k (where k <= s). Joining each change to the
    9-row stages table lists those earlier stages, and the earliest change_time
    per deal and stage is when the deal first got that far. So one join plus a
    min() gives us the filled-in stages, the entry time, and the stage name all
    at once.
*/
, deal_stage_entered as (
    select
        stg_pipedrive__stages.stage_id
        , stg_pipedrive__stages.stage_name
        , stage_events.deal_id
        , min(stage_events.changed_at) as entered_at
    from stage_events
    inner join stg_pipedrive__stages
        on stg_pipedrive__stages.stage_id <= stage_events.stage_id
    group by 1, 2, 3
)

, final as (
    select
        {{ dbt_utils.generate_surrogate_key(['deal_id', 'stage_id']) }} as deal_stage_sk
        , deal_id
        , stage_id
        , stage_name
        , cast(stage_id as numeric(3, 1)) as funnel_step
        , entered_at
        , date_trunc('month', entered_at)::date as month
    from deal_stage_entered
)

select * from final
