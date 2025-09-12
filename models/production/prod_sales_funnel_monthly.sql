with deals_with_kpis as (
    select * from {{ ref('int_deals_with_kpis') }} 
),
unpivoted as (
    select
        deal_stage_change_id,
        date_trunc('month', valid_from)::date as month,
        funnel_step as kpi_name,
        funnel_step
    from deals_with_kpis
    where funnel_step is not null
    union all
    select
        deal_stage_change_id,
        date_trunc('month', valid_from)::date as month,
        funnel_sub_step as kpi_name,
        funnel_step
    from deals_with_kpis
    where funnel_sub_step is not null
),
final as (
    select
        month,
        kpi_name,
        funnel_step,
        count(distinct deal_stage_change_id) as deals_entered_stage_count
    from unpivoted
    group by 1, 2, 3
)
select * from final
order by month, funnel_step