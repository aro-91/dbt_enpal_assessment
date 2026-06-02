/*
    Macro: last_record_per_group
    ─────────────────────────────
    Returns the most recent row per partition, ordered by a timestamp column.

    Abstracts over database-specific syntax:
      - Postgres:           DISTINCT ON   (index-friendly, very fast)
      - Snowflake/BigQuery/Redshift: ROW_NUMBER() window function

    Usage:
        {{ last_record_per_group(
            source      = ref('stg_deal_changes'),
            partition   = ['deal_id'],
            order_by    = 'changed_at',
            select_cols = ['deal_id', 'new_value']
        ) }}

    Parameters:
      source      – table ref or CTE name (passed as a string for flexibility)
      partition   – list of columns to partition by
      order_by    – column to sort descending (latest = rank 1)
      select_cols – list of columns to return
*/

{% macro last_record_per_group(source, partition, order_by, select_cols) %}

{% set partition_str = partition | join(', ') %}
{% set cols_str      = select_cols | join(', ') %}

{% if target.type == 'postgres' %}

    select distinct on ({{ partition_str }})
        {{ cols_str }}
    from {{ source }}
    order by {{ partition_str }}, {{ order_by }} desc nulls last

{% else %}

    select {{ cols_str }}
    from (
        select
            {{ cols_str }},
            row_number() over (
                partition by {{ partition_str }}
                order by {{ order_by }} desc nulls last
            ) as _rn
        from {{ source }}
    ) _ranked
    where _rn = 1

{% endif %}

{% endmacro %}
