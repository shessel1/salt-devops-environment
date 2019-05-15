{% set install = salt.pillar.get("vault:install") %}
{% set config = salt.pillar.get("vault:config") %}

vault_config_file:
  file.serialize:
    - name: {{ install.config_file }}
    - formatter: json
    - dataset: {{ config }}
    - makedirs: True

vault_service:
  service.running:
    - name: vault
    - enable: True
    - require:
      - file: vault_config_file
    - watch:
      - file: vault_config_file
