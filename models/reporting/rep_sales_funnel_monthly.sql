{{ config(materialized='table') }}

with events as (
  select
    date_trunc('month', occurred_at)::date as month,
    kpi_name,
    funnel_step,
    deal_id
  from {{ ref('int_funnel_events') }}
),

dedup as (
  select distinct
    month, kpi_name, funnel_step, deal_id
  from events
)

select
  month,
  kpi_name,
  funnel_step,
  count(distinct deal_id) as deals_count
from dedup
group by 1,2,3
order by 1,3
