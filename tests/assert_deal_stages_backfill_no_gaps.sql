{#
    Checks: every deal's reached-stage set in trns_deal_stages_backfill is a
    contiguous run from 1 to its highest stage, with no numbers missing
    in between.
#}

with deal_stage_counts as (

    select
        deal_id
        , count(*)          as stages_reached
        , max(stage_id)      as max_stage

    from {{ ref('trns_deal_stages_backfill') }}
    group by deal_id

)

select *
from deal_stage_counts
where stages_reached <> max_stage
