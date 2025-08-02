{%- macro jsonb_extract_null_missing(field_name, jsonb_key, value_to_set_null = '') -%}
    NULLIF(jsonb_array_elements({{ field_name }}) ->> '{{ jsonb_key }}', '{{ value_to_set_null }}')
{%- endmacro -%}