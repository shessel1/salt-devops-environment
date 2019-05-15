{% set install = salt.pillar.get("consul:install") %}
{% set config = salt.pillar.get("consul:config") %}

{% for name, content in config.items() %}
consul_config_{{ name }}:
  file.serialize:
    - name: {{ install.config_dir }}/{{ name }}.json
    - formatter: json
    - dataset: {{ content | json }}
    - makedirs: True
{% endfor %}

consul_service:
  service.running:
    - name: consul
    - enable: True
    - require:
      - file: consul_service_file
    - watch:
      - file: consul_service_file
      - file: {{ install.config_dir }}/*
