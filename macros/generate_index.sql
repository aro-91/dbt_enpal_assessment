{% macro generate_index(table_name, column_name) %}
    CREATE INDEX IF NOT EXISTS idx_{{ table_name.name }}_{{ column_name }} ON {{ table_name }} ({{ column_name }})
{% endmacro %}
