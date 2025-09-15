-- Intermediate model to get possible combination of month-year and funnel steps
-- This is a helper table


{% set activity_deals_funnel = ref('int_activity_deals_funnel') %}


with month_years as (

    select distinct month_year
    from {{activity_deals_funnel}}

),

funnel_steps as (

    select distinct funnel_step, kpi_name
    from {{activity_deals_funnel}}

)

select
       my.month_year,
       fs.funnel_step,
       fs.kpi_name
from month_years my
cross join funnel_steps fs
 