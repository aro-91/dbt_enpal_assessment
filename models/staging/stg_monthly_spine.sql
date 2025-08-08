WITH date_range as
    (
        SELECT
            MIN(DATE_TRUNC('month', change_time)::DATE) AS monthstart ,
            MAX(DATE_TRUNC('month', change_time)::DATE) AS monthend
        FROM
            {{ ref('stg_deal_changes')}}

    ),

monthly_spine as (
    SELECT generate_series(
           (SELECT monthstart FROM date_range),
           (SELECT monthend FROM date_range),
           INTERVAL '1 month'
           )::date AS month
),
funnels as (
select
	stage_id::varchar,
    stage_name as kpi_name,
    'Step_'||stage_id as funnel_step
from {{ ref('stg_deal_stages')}}
union
select
activity_key as stage_id,
activity_type_name as kpi_name,
case when activity_key = 'meeting' then 'Step_2.1' else 'Step_3.1' end as funnel_step
from {{ ref('stg_activity_types')}}
where activity_key in ('meeting','sc_2')
)

SELECT
    stage_id::varchar(20),
    kpi_name::varchar(50),
    funnel_step::varchar(10),
    month
FROM
    monthly_spine
    CROSS JOIN funnels
