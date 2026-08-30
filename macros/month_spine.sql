{% macro month_spine(start_date, end_date) %}
-- returns month spine dependend on range
-- using recursive over date_spine as row count is not known at runtime
-- Postgres and Snowflake compatible, not BigQuery

    with recursive month_spine as (

        select date_trunc('month', {{ start_date }}::date)::date as month

        union all

        select ({{ dbt.dateadd('month', 1, 'month') }})::date
        from month_spine
        where month < date_trunc('month', {{ end_date }}::date)::date

    )

    select month
    from month_spine

{% endmacro %}
