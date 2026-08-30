{#
    PROPOSED REPORT. Not part of the data model: run manually, not built
    or tested. If approved, promote into models/03_mart/ with a
    schema.yml entry.

    No native Pipedrive equivalent. It slices the same "how many deals
    reached each stage" question by current owner instead of by month,
    and it is the only use of the 2,500 user_id events in deal_changes.

    Grain: one row per deal owner and funnel_step. Stage steps only, for
    the disjoint-id-space reason given in the other reports here.

    501 of 1,995 deals were reassigned at least once; the most recent
    user_id event wins. Owners with no qualifying deal are omitted rather
    than zero-filled across 1,347 owners x 9 stages.
#}

with stg_pipedrive__deal_changes as (

    select * from {{ ref('stg_pipedrive__deal_changes') }}

),

trns_deal_stages_backfill as (

    select * from {{ ref('trns_deal_stages_backfill') }}

),

users as (

    select * from {{ source('pipedrive', 'users') }}

),

trns_deal_stage_funnel as (

    select * from {{ ref('trns_deal_stage_funnel') }}

),

latest_owner as (
    {#- ROW_NUMBER over changed_at desc, not DISTINCT ON -- portable to
       warehouses that don't support Postgres's DISTINCT ON syntax #}

    select deal_id, user_id
    from (
        select
            deal_id
            , new_value::int    as user_id
            , row_number() over (
                partition by deal_id
                order by changed_at desc
              )    as rn

        from stg_pipedrive__deal_changes
        where changed_field_key = 'user_id'
    ) as ranked
    where rn = 1

),

deal_stages_reached as (

    select distinct
        deal_id
        , stage_id

    from trns_deal_stages_backfill

),

owner_stage_counts as (

    select
        latest_owner.user_id
        , deal_stages_reached.stage_id
        , count(distinct latest_owner.deal_id)    as deals_count

    from latest_owner
    inner join deal_stages_reached
        on latest_owner.deal_id = deal_stages_reached.deal_id
    group by 1, 2

),

final as (

    select
        users.name                            as owner_name
        , users.email                         as owner_email
        , trns_deal_stage_funnel.kpi_name
        , trns_deal_stage_funnel.stage_id::text    as funnel_step
        , owner_stage_counts.deals_count

    from owner_stage_counts
    inner join users
        on owner_stage_counts.user_id = users.id
    inner join trns_deal_stage_funnel
        on owner_stage_counts.stage_id = trns_deal_stage_funnel.stage_id

)

select * from final
order by 1, 4
