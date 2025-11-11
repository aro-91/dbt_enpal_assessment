{{ config(materialized='table') }}

with funnel_steps as (
    select *
    from (values
        (1, 'Step 1: Lead Generation'),
        (2, 'Step 2: Qualified Lead'),
        (2.1, 'Step 2.1: Sales Call 1'),
        (3, 'Step 3: Needs Assessment'),
        (3.1, 'Step 3.1: Sales Call 2'),
        (4, 'Step 4: Proposal/Quote Preparation'),
        (5, 'Step 5: Negotiation'),
        (6, 'Step 6: Closing'),
        (7, 'Step 7: Implementation/Onboarding'),
        (8, 'Step 8: Follow-up/Customer Success'),
        (9, 'Step 9: Renewal/Expansion')
    ) as t(step_number, funnel_step)
),

-- aggregated deal_stages on monthly level
aggregated_stage as (
    select
        date_trunc('month', change_month)::date as month,
        {{ stage_to_step('stage_id') }} as funnel_step,
        count(distinct deal_id) as deals_count
    from {{ ref('stg_stage_changes') }}
    group by 1,2
),

-- aggregated activities on monthly level
aggregated_activity as (
    select
        date_trunc('month', due_date)::date as month,
        {{ activity_to_step('type') }} as funnel_step,
        count(distinct deal_id) as deals_count
    from {{ ref('stg_activity') }}
    where done = true
    group by 1,2
),

-- unioning in order to capture all funnel step activities
aggregated_all as (
    select * from aggregated_stage
    union all
    select * from aggregated_activity
),

final as (
    select
        a.month,
        f.funnel_step as kpi_name,
        coalesce(sum(a.deals_count),0) as deals_count,
        f.step_number
    from funnel_steps f
    left join aggregated_all a
        on a.funnel_step = f.funnel_step
    group by a.month, f.step_number, f.funnel_step
)

select
    month,
    kpi_name,
    deals_count
from final
order by month, step_number
