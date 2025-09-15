-- Intermediate model for mapping activities to funnel steps
-- Maps activities to their corresponding sales funnel stages

{% set activities = ref('raw_fact_activities') %}
{% set activity_types = ref('raw_dim_activity_types') %}


with 
-- Map activities to funnel steps based on activity type
activity_funnel_mapping as (
   select
       a.activity_id,
       a.type as activity_type,
       at.name,
       a.assigned_to_user,
       a.deal_id,
       a.done as is_completed,
       a.due_to as due_date,
       {{ get_activity_status('a.done', 'a.due_to') }} as activity_status,
       a.due_month,
       a.due_year,
       a.due_month_year
   from {{activities}} a
   left join {{activity_types}} at
   on a.type = at.type
)


select * 
from activity_funnel_mapping