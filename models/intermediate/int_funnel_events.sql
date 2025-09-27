{{ config(materialized='view') }}

{# Define CTEs: name, ref target, and which column holds the month #}
{% set cte_specs = [
    {'name': 'stage_events',    'ref': 'int_deal_stage_changes', 'month_src': 'month'},
    {'name': 'activity_events', 'ref': 'int_activity_calls',     'month_src': 'month_start'}
] %}

WITH
{% for spec in cte_specs %}
{{ spec.name }} AS (
    SELECT
        src.deal_id,
        {%- if spec.month_src == 'month' %}
        src.month AS month,
        {%- else %}
        src.month_start AS month,
        {%- endif %}
        src.kpi_name,
        src.funnel_step,
        src.sort_order
    FROM {{ ref(spec.ref) }} AS src
){% if not loop.last %},{% endif %}
{% endfor %}

{% for spec in cte_specs %}
SELECT
    {{ spec.name }}.deal_id,
    {{ spec.name }}.month,
    {{ spec.name }}.kpi_name,
    {{ spec.name }}.funnel_step,
    {{ spec.name }}.sort_order
FROM {{ spec.name }}
{% if not loop.last %}UNION ALL
{% endif %}
{% endfor %}

