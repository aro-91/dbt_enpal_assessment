{% test stage_dates_increase(model, group_by, sort_by, date_col) %}

    select *
    from (
        select
            {{ group_by }},
            {{ sort_by }},
            {{ date_col }},
            lag({{ date_col }}) over (partition by {{ group_by }} order by {{ sort_by }}) as prev_date
        from {{ model }}
    ) validation
    where {{ date_col }} < prev_date

{% endtest %}
