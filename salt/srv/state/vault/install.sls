{% set install = salt.pillar.get("vault:install") %}

vault_group:
  group.present:
    - name: {{ install.group }}

vault_user:
  user.present:
    - name: {{ install.user }}
    - groups:
      - {{ install.group }}
    - createhome: False
    - system: True
    - require:
      - group: vault_group

vault_binary:
  archive.extracted:
    - name: /usr/local/bin
    - source: https://releases.hashicorp.com/vault/{{ install.version }}/vault_{{ install.version }}_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/vault/{{ install.version }}/vault_{{ install.version }}_SHA256SUMS
    - enforce_toplevel: False
    - if_missing: /usr/local/bin/vault

vault_service_file:
  file.managed:
    - name: /etc/systemd/system/vault.service
    - source: {{ install.service_file }}
    - template: jinja
    - mode: 0640