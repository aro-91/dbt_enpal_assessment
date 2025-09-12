{% macro generate_schema_name(custom_schema_name, node) -%}
  {# 
    Returns:
    - <custom_schema_name> + dev_suffix if dev_suffix is defined
    - <custom_schema_name> as-is if dev_suffix is empty
    - target.schema from profiles.yml if custom_schema_name is not set
  #}

  {% set suffix = var('dev_suffix', '') %}

  {% if custom_schema_name is none %}
    {{ target.schema }}
  {% else %}
    {% if suffix != '' %}
      {{ custom_schema_name }}_{{ suffix | lower }}
    {% else %}
      {{ custom_schema_name }}
    {% endif %}
  {% endif %}

{%- endmacro %}
