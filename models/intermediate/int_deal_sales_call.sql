with stg_pipedrive__activity as (
    select * from {{ ref('stg_pipedrive__activity') }}
)

, stg_pipedrive__activity_types as (
    select * from {{ ref('stg_pipedrive__activity_types') }}
)

/*
    Steps 2.1 (Sales Call 1) and 3.1 (Sales Call 2) only count completed
    activities (is_done is true), not scheduled/pending ones. The 2.1/3.1
    step numbers and the activity_type_code -> kpi_name mapping below are
    fixed by the assessment brief's funnel definition, hence the hard-coded
    case statement rather than a join to a reference table.

    No deal has more than one completed activity of the same type, so
    (deal_id, funnel_step) is a safe grain for the surrogate key below.
*/
, completed_sales_calls as (
    select
        deal_id
        , activity_type_code
        , due_at
    from stg_pipedrive__activity
    where activity_type_code in ('meeting', 'sc_2')
        and is_done is true
)

, final as (
    select
        {{ dbt_utils.generate_surrogate_key(['completed_sales_calls.deal_id', 'completed_sales_calls.activity_type_code']) }} as deal_sales_call_sk
        , completed_sales_calls.deal_id
        , stg_pipedrive__activity_types.activity_type_name as kpi_name
        , cast(
            case completed_sales_calls.activity_type_code
                when 'meeting' then 2.1
                when 'sc_2' then 3.1
            end as numeric(3, 1)
        ) as funnel_step
        , completed_sales_calls.due_at
        , date_trunc('month', completed_sales_calls.due_at)::date as month
    from completed_sales_calls
    inner join stg_pipedrive__activity_types
        on completed_sales_calls.activity_type_code = stg_pipedrive__activity_types.activity_type_code
)

select * from final
