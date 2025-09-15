-- Build actual result given inputs
with dbt_internal_unit_test_actual as (
  select
    month,kpi_name,funnel_step,deals_count, 'actual' as "actual_or_expected"
  from (
    -- Monthly sales funnel reporting model





with  __dbt__cte__int_month_funnel_matrix as (
SELECT '2025-09' AS month_year,
       'kpi_1' AS kpi_name,
       'step_1' AS funnel_step
),  __dbt__cte__int_activity_deals_funnel as (
SELECT '2025-09' AS month_year,
       'kpi_1' AS kpi_name,
       'step_1' AS funnel_step,
       1 AS deal_id
UNION ALL
SELECT '2025-09', 'kpi_1', 'step_1', 2
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
  ) _dbt_internal_unit_test_actual
),
-- Build expected result
dbt_internal_unit_test_expected as (
  select
    month, kpi_name, funnel_step, deals_count, 'expected' as "actual_or_expected"
  from (
    SELECT '2025-09' AS month,
       'kpi_1' AS kpi_name,
       'step_1' AS funnel_step,
       2 AS deals_count
  ) _dbt_internal_unit_test_expected
)
-- Union actual and expected results
select * from dbt_internal_unit_test_actual
union all
select * from dbt_internal_unit_test_expected