{#
    Checks: every deal_id that appears anywhere in deal_changes has at
    least one add_time event.

    This protects the add_time assumption the proposed cohort-conversion
    analysis depends on for its cohort_month. No model reads add_time
    today, and that is deliberate -- see
    analyses/additional_rep_models/rep_sales_funnel_cohort_conversion.sql.
#}

select deal_id
from {{ ref('stg_pipedrive__deal_changes') }}
group by deal_id
having sum(case when changed_field_key = 'add_time' then 1 else 0 end) = 0
