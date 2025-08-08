-- This macro overrides dbt's default behavior for generating schema names.
-- It will use the custom schema name defined in dbt_project.yml directly.
-- If no custom schema is defined, it will fall back to the default schema
-- specified in your profiles.yml.
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is not none -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}

    {%- endif -%}

{%- endmacro %}