{% macro convert_pct(col) %}
  CAST(REPLACE({{ col }}, '%', '') AS DOUBLE) / 100
{% endmacro %}
