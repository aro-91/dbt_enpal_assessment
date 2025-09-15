-- Intermediate model for combining deal stages with activities data

{% set deal_stage = ref('int_deal_stage_progression') %}
{% set activity_funnel = ref('int_activity_funnel_mapping') %}

with deal_stage as (

    select deal_id,
           new_stage_id as funnel_step,
           stage_name as kpi_name,
           change_month_year as month_year,
           '{{deal_stage}}'as source

    from {{deal_stage}}

),

activity_funnel as (
    select deal_id,
        {{ get_funnel_step('name') }} as funnel_step,
        {{ get_kpi_name('name') }} as kpi_name,
        due_month_year as month_year,
        '{{activity_funnel}}'as source
    from {{activity_funnel}}
),

funnel_union as (
    
    select * from deal_stage

    union all 
   
    select * from activity_funnel

)

select *
from funnel_union