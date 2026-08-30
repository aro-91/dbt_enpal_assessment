{#
    Purpose: Backfills previous stages per deal_id, following Pipedrive's
    own approach for the progress report.

    Grain: one row per deal_id and stage_id.

    Note: the 8 apparent backward moves in this dataset belong to 5
    colliding deal_ids (each carries two independent deals' event streams
    under one id). Split by the generator's per-deal time-of-day, every
    stage run is monotonic, so the forward-only assumption holds for this
    dataset. A production model on real data would still need to handle
    genuine backward moves.

    The `previous_stage_id is null then 1` branch never fires here,
    because every deal's first stage event is stage 1. It is defensive
    and the data does not exercise it.
#}

with stg_pipedrive__deal_changes as (

    select * from {{ ref('stg_pipedrive__deal_changes') }}

),

trns_deal_stage_funnel as (

    select * from {{ ref('trns_deal_stage_funnel') }}

),

stage_changes as (
    {# pull every stage_id change event for every deal from deal_changes #}

    select
        deal_id
        , new_value::int    as stage_id
        , changed_at

    from stg_pipedrive__deal_changes
    where changed_field_key = 'stage_id'

),

with_previous as (
    {# select each change, with their previous change #}

    select
        deal_id
        , stage_id
        , changed_at
        , lag(stage_id) over (partition by deal_id order by changed_at)
            as previous_stage_id

    from stage_changes

),

range_bounds as (
    {# per deal change, the [start, stop] stage range for backfill #}

    select
        deal_id
        , changed_at    as entered_at
        , case
            when previous_stage_id is null then 1
            when stage_id > previous_stage_id then previous_stage_id + 1
            else stage_id
          end as range_start
        , stage_id as range_end

    from with_previous

),

deal_stages as (
    {# valid stage numbers, from the live field metadata #}

    select stage_id
    from trns_deal_stage_funnel

),

backfilled as (
    {# backfills all deal stages per deal between first and last reached
       stage, following Pipedrive's own Progress Report approach for a
       clean funnel #}

    select
        range_bounds.deal_id
        , range_bounds.entered_at
        , deal_stages.stage_id

    from range_bounds
    inner join deal_stages
        on deal_stages.stage_id
            between range_bounds.range_start and range_bounds.range_end

),

first_reached as (
    {# select the earliest time a deal entered a stage #}

    {{ first_event_by_grain('backfilled', 'deal_id, stage_id', 'entered_at') }}

),

final as (

    select
        deal_id
        , stage_id
        , entered_at    as reached_at

    from first_reached

)

select * from final
