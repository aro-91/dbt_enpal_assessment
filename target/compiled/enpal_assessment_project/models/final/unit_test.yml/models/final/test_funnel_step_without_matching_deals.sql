-- Monthly sales funnel reporting model





with  __dbt__cte__int_month_funnel_matrix as (
SELECT '2025-09' AS month_year,
       'kpi_2' AS kpi_name,
       'step_2' AS funnel_step
),  __dbt__cte__int_activity_deals_funnel as (
SELECT NULL::text AS month_year,
       NULL::text AS kpi_name,
       NULL::text AS funnel_step,
       NULL::int AS deal_id
), deals AS (

    select month_year,
           kpi_name,
           funnel_step,
       count(distinct deal_id) deals_count
from __dbt__cte__int_activity_deals_funnel

group by month_year,
         kpi_name,
         funnel_step
)


select mfm.month_year as month,
       mfm.kpi_name,
       mfm.funnel_step,
       coalesce(d.deals_count,0) deals_count
from __dbt__cte__int_month_funnel_matrix mfm 
left join deals d

on mfm.month_year = d.month_year
and mfm.funnel_step = d.funnel_step