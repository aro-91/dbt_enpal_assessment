{% macro get_funnel_step(name_column) %}
    /*
      Input:
        - name_column (string): The column name containing the activity name (e.g., 'Sales Call 1')

      Output:
        - Numeric value representing the funnel step for that activity
    */
    case
        when {{ name_column }} = 'Sales Call 1' then 2.1
        when {{ name_column }} = 'Sales Call 2' then 3.1
        when {{ name_column }} = 'Follow Up Call' then 8
        when {{ name_column }} = 'After Close Call' then 9
    end
{% endmacro %}
