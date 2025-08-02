{%- macro mask_field(field_name, method='sha256') -%}
  {%- if method == 'sha256' -%}
    encode(digest('{{ var("mask_salt") }}' || {{ field_name }}, 'sha256'), 'hex')
  {%- endif -%}
{%- endmacro -%}