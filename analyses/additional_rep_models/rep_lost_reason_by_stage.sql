{#
    PROPOSED REPORT. Not part of the data model: run manually, not built
    or tested. If approved, promote into models/03_mart/ with a
    schema.yml entry.

    No native Pipedrive equivalent. It answers "why, and where, are we
    losing deals".

    Grain: one row per funnel_step and lost_reason label. Stage steps
    only, for the disjoint-id-space reason given in the other reports
    here. Each deal is assigned the highest stage it had reached as of
    the moment it was marked lost.

    The numbers today mean nothing. lost_reason is set on all 1,995
    deals, and the 5 reasons split evenly within every stage in
    proportion to how many deals reach it. The shape is worth having once
    outcomes are tracked; see findings_and_approach.md.
#}

with stg_pipedrive__deal_changes as (

    select * from {{ ref('stg_pipedrive__deal_changes') }}

),

stg_pipedrive__fields as (

    select * from {{ ref('stg_pipedrive__fields') }}

),

trns_deal_stages_backfill as (

    select * from {{ ref('trns_deal_stages_backfill') }}

),

trns_deal_stage_funnel as (

    select * from {{ ref('trns_deal_stage_funnel') }}

),

lost_events as (

    select
        deal_id
        , new_value      as lost_reason_code
        , changed_at     as lost_at

    from stg_pipedrive__deal_changes
    where changed_field_key = 'lost_reason'

),

lost_reason_labels as (

    select
        opt ->> 'id'       as lost_reason_code
        , opt ->> 'label'  as lost_reason_label

    from stg_pipedrive__fields
    cross join jsonb_array_elements(field_value_options) as opt
    where field_key = 'lost_reason'

),

stage_at_loss as (

    select
        lost_events.deal_id
        , lost_events.lost_reason_code
        , max(trns_deal_stages_backfill.stage_id)    as stage_id

    from lost_events
    inner join trns_deal_stages_backfill
        on lost_events.deal_id = trns_deal_stages_backfill.deal_id
        and trns_deal_stages_backfill.reached_at <= lost_events.lost_at
    group by 1, 2

),

final as (

    select
        trns_deal_stage_funnel.kpi_name
        , trns_deal_stage_funnel.stage_id::text    as funnel_step
        , lost_reason_labels.lost_reason_label
        , count(distinct stage_at_loss.deal_id)      as deals_lost

    from stage_at_loss
    inner join lost_reason_labels
        on stage_at_loss.lost_reason_code = lost_reason_labels.lost_reason_code
    inner join trns_deal_stage_funnel
        on stage_at_loss.stage_id = trns_deal_stage_funnel.stage_id

    group by 1, 2, 3

)

select * from final
order by 2, 4 desc
