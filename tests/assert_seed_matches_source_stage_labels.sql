{#
    Checks: seeds/funnel_steps.csv's stage labels (kpi_name, where
    source_type = 'stage') match trns_deal_stage_funnel
    (Pipedrive's own field metadata) exactly.
#}

select
    coalesce(
        funnel_steps.stage_id
        , trns_deal_stage_funnel.stage_id
      )    as stage_id
    , funnel_steps.kpi_name                as seed_kpi_name
    , trns_deal_stage_funnel.kpi_name    as source_kpi_name

from {{ ref('funnel_steps') }}
full outer join {{ ref('trns_deal_stage_funnel') }}
    on funnel_steps.stage_id = trns_deal_stage_funnel.stage_id
where funnel_steps.source_type = 'stage'
  and (funnel_steps.kpi_name is distinct from trns_deal_stage_funnel.kpi_name)
