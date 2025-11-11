{% macro activity_to_step(activity_type) %}
    case {{ activity_type }}
        when 'meeting' then 'Step 2.1: Sales Call 1'
        when 'sc_2' then 'Step 3.1: Sales Call 2'
        when 'after_close_call' then 'Step 8: Follow-up/Customer Success'
        when 'follow_up' then 'Step 8: Follow-up/Customer Success'
        else null
    end
{% endmacro %}
