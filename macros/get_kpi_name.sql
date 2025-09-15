{% macro get_kpi_name(name_column) %}
    /*
      Input:
        - name_column (string): name of the column to apply the mapping on

      Output:
        - A string: the standardized KPI name
    */
    
    case
        when {{ name_column }} in ('Sales Call 1', 'Sales Call 2') then {{ name_column }}
        when {{ name_column }} = 'Follow Up Call' then 'Follow-up/Customer Success'
        when {{ name_column }} = 'After Close Call' then 'Renewal/Expansion'
        else NULL
    end
{% endmacro %}