{% macro get_activity_status(done_column, due_to_column) %}
/*    Inputs:
        - done_column (string): column name that indicates if the task is completed
        - due_to_column (string): column name with the due timestamp

      Output:
        - A string: 'Completed', 'Overdue', or 'Pending'
    */
    case
        when {{ done_column }} = true then 'Completed'
        when {{ due_to_column }} < current_timestamp then 'Overdue'
        else 'Pending'
    end
{% endmacro %}
