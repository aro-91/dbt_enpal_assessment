/*
    Macro: generate_monthly_spine
    ──────────────────────────────
    Generates a series of month-start dates between two date bounds.

    Abstracts over database-specific date generation:
      - Postgres:   generate_series()
      - Snowflake:  GENERATOR + DATEADD
      - BigQuery:   GENERATE_DATE_ARRAY
      - Redshift:   recursive CTE fallback

    Usage:
        {{ generate_monthly_spine(
            start_expr = "(select min(changed_at) from " ~ ref('stg_deal_changes') ~ ")",
            end_expr   = "(select max(changed_at) from " ~ ref('stg_deal_changes') ~ ")"
        ) }}

    Returns a single column: reporting_month (date, first day of each month).
*/

{% macro generate_monthly_spine(start_expr, end_expr) %}

{% if target.type == 'postgres' %}

    select
        date_trunc('month', gs)::date as reporting_month
    from generate_series(
        ({{ start_expr }})::date,
        ({{ end_expr }})::date,
        '1 month'::interval
    ) as gs

{% elif target.type == 'snowflake' %}

    select
        dateadd('month', seq4(), date_trunc('month', ({{ start_expr }})::date)) as reporting_month
    from table(generator(rowcount => 1000))
    where reporting_month <= date_trunc('month', ({{ end_expr }})::date)

{% elif target.type == 'bigquery' %}

    select reporting_month
    from unnest(
        generate_date_array(
            date_trunc(({{ start_expr }}), month),
            date_trunc(({{ end_expr }}), month),
            interval 1 month
        )
    ) as reporting_month

{% else %}

    -- Redshift / generic fallback: recursive CTE (max 500 months ≈ 41 years)
    with recursive monthly_spine as (
        select date_trunc('month', ({{ start_expr }})::date)::date as reporting_month
        union all
        select (reporting_month + interval '1 month')::date
        from monthly_spine
        where reporting_month < date_trunc('month', ({{ end_expr }})::date)::date
    )
    select reporting_month from monthly_spine

{% endif %}

{% endmacro %}
