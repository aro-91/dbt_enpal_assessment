{#
    This test checks if recent values of a column exceed dynamically calculated thresholds.
    The thresholds are averages of historical data that may be adjusted using multipliers
    (threshold = multiplier * average). These averages do not include the most recent data to
    avoid skewing the test.

    If added to a model's column in its YML, 'model' and 'column_name' are automatically passed.

    Macro parameters:
    - model: The model being tested, which contains the column of interest.
    - column_name: The name of the column whose values are evaluated against the dynamically calculated thresholds.
    - group_by_column: Optional. The column used to group data for calculating thresholds (default: none).
    - time_period_unit_historical: The time unit for historical data retrieval ('day', 'week', or 'month'; default: 'day').
    - time_period_value_historical: The number of units for the historical time range (default: 28).
    - date_column: Optional. The date column used to filter historical data; if not specified, no date filter is applied (default: none).
    - upper_multiplier: The factor used to adjust the upper threshold (default: 1.5).
    - lower_multiplier: Optional. The factor, between 0 and 1, used to adjust the lower threshold; if not provided, no lower threshold is tested (default: none).
    - time_period_unit_test: The time unit for the current data retrieval ('day', 'week', or 'month'; default: 'day').
    - time_period_value_test: The number of units for the current data time range (default: 7).
    - row_condition: Optional. SQL conditions to filter the test data (e.g., 'some_column < some_value'). These are added using an 'and', so no need to add 'where'. Combine conditions using boolean operators (default: none).
#}

{% test dynamic_threshold
    (
        model
        , column_name
        , group_by_column=none
        , time_period_unit_historical='day'
        , time_period_value_historical=28
        , date_column=none
        , upper_multiplier=1.5
        , lower_multiplier=none
        , time_period_unit_test='day'
        , time_period_value_test=7
        , row_condition=none
    )
%}

    {# Postgres interval helper: builds e.g. interval '28 day', '6 month', etc. #}
    {% set historical_interval = "interval '" ~ time_period_value_historical ~ " " ~ time_period_unit_historical ~ "'" %}
    {% set test_interval = "interval '" ~ time_period_value_test ~ " " ~ time_period_unit_test ~ "'" %}

    -- Base query to fetch historical data for the column
    with historical_data as (
        select
            avg({{ column_name }}) + max({{ column_name }}) as historical_value_max
            , min({{ column_name }}) as historical_value_min
            {% if group_by_column is not none %}
                , {{ group_by_column }}
            {% endif %}
        from {{ model }}
        where 1 = 1
        {% if date_column is not none %}
            and {{ date_column }}::date >= (current_date - {{ historical_interval }})
            and {{ date_column }}::date < (current_date - {{ test_interval }})
        {% endif %}
        {% if row_condition is not none %}
            and {{ row_condition }}
        {% endif %}
        {% if group_by_column is not none %}
            group by {{ group_by_column }}
        {% endif %}
    ),

    -- Calculating the threshold by multiplying the historical value
    threshold_data as (
        select
            (historical_value_max * {{ upper_multiplier }}) as upper_threshold
            {% if lower_multiplier is not none %}
                , (historical_value_min * {{ lower_multiplier }}) as lower_threshold
            {% endif %}
            {% if group_by_column is not none %}
                , {{ group_by_column }}
            {% endif %}
        from historical_data
        where (historical_value_max * {{ upper_multiplier }}) != 0
    ),

    -- Current data to compare against the threshold
    test_data as (
        select
            {{ column_name }} as current_value
            {% if group_by_column is not none %}
                , {{ group_by_column }}
            {% endif %}
        from {{ model }}
        where 1 = 1
        {% if date_column is not none %}
           and {{ date_column }}::date >= (current_date - {{ test_interval }})
        {% endif %}
        {% if row_condition is not none %}
            and {{ row_condition }}
        {% endif %}
    ),

    violations as (
        select
            current_value
            {% if group_by_column is not none %}
                , test_data.{{ group_by_column }} as group_value
            {% endif %}
        from test_data
        join threshold_data
            {% if group_by_column is not none %}
                on test_data.{{ group_by_column }} = threshold_data.{{ group_by_column }}
            {% else %}
                on 1 = 1
            {% endif %}
        where current_value > upper_threshold
        {% if lower_multiplier is not none %}
            or current_value < lower_threshold
        {% endif %}
    )

    select *
    from violations

{% endtest %}
