{% macro export_to_parquet(model) %}

    {% call statement('export_command', fetch_result=False, auto_begin=True) -%}
      COPY (SELECT * FROM {{ model }} ) TO '{{ env_var("MELTANO_PROJECT_ROOT") }}/data/catalog/{{ model.name }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');
    {% endcall %}

{% endmacro %}