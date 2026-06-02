/*
    Macro: end_of_month_ts
    ───────────────────────
    Returns a timestamp representing the very last moment of the month
    containing the given date expression. Used for point-in-time "as of
    month end" comparisons.

    The exact expression varies by dialect:
      - Postgres:   month_col + interval '1 month' - interval '1 second'
      - Snowflake:  DATEADD('second', -1, DATEADD('month', 1, DATE_TRUNC('month', month_col)))
      - BigQuery:   DATETIME_SUB(DATE_TRUNC(DATE_ADD(month_col, INTERVAL 1 MONTH), MONTH), INTERVAL 1 SECOND)
      - Redshift:   same pattern as Postgres

    Usage:
        where event_timestamp <= {{ end_of_month_ts('reporting_month') }}

    Parameters:
      month_col – a date column representing the first day of the month
                  (as produced by generate_monthly_spine or date_trunc('month',...))
*/

{% macro end_of_month_ts(month_col) %}

{% if target.type in ('postgres', 'redshift') %}

    ({{ month_col }} + interval '1 month' - interval '1 second')

{% elif target.type == 'snowflake' %}

    dateadd('second', -1, dateadd('month', 1, date_trunc('month', {{ month_col }})))

{% elif target.type == 'bigquery' %}

    datetime_sub(
        cast(date_trunc(date_add(cast({{ month_col }} as date), interval 1 month), month) as datetime),
        interval 1 second
    )

{% else %}

    ({{ month_col }} + interval '1 month' - interval '1 second')

{% endif %}

{% endmacro %}
