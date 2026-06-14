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
    Pipedrive's native funnel/conversion report counts a deal as having
    "entered" every stage up to the furthest stage it reached, including stages
    it skipped over (e.g. a deal that moved 2 -> 5 also counts in stages 3 and
    4). ~84% of deals in this data skip at least one prior stage, so we back-fill.

    A stage-change event to stage s is evidence the deal reached "stage k or
    beyond" for every k <= s, so each event contributes a candidate entry time
    to every stage k <= s. Taking MIN(changed_at) per (deal, stage k) gives the
    first time the deal reached stage k or later. The join to the 9-row stages
    table both enumerates k = 1..(deal's furthest stage) and supplies stage_name,
    so the back-fill, the entry time, and the stage label all fall out of one
    aggregate.
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
