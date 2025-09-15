{% macro generate_schema_name(custom_schema_name, node) %}
    {#
      Custom schema naming macro.

      Prevents dbt from prefixing the schema with the target schema (e.g., "public").
      Returns only the custom schema defined in the dbt_project.yml file.

      Example:
        +schema: private_pipedrive_analytics
        → Builds directly into that schema (not public_private_pipedrive_analytics)
    #}
    {{ custom_schema_name | trim }}
{% endmacro %}
