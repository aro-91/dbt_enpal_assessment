{{ config(materialized='table') }}

select *
from {{ ref('int_deal_stage_progression') }}
order by month, kpi_name