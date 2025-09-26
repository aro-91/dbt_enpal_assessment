{{ config(
  materialized='table',
  indexes=[
    {'columns': ['month']},
    {'columns': ['funnel_step','month']}
  ]
) }}

with src as (
    select TO_CHAR(funnel_events.funnel_event_at, 'YYYY-MM') as month,
           funnel_events.funnel_event_name                   as kpi_name,
           funnel_events.funnel_event_step                   as funnel_step,
           count(distinct funnel_events.funnel_event_id)     as deals_count 
    from  {{ ref('int_funnel_events') }} as funnel_events
    group by month,kpi_name,funnel_step
    )

select * from src