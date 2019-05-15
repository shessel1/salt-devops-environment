{% set consul = salt.pillar.get("consul:install", {}) %}

consul_group:
  group.present:
    - name: {{ consul.group }}

consul_user:
  user.present:
    - name: {{ consul.user }}
    - groups:
      - {{ consul.group }}
    - createhome: False
    - system: True
    - require:
      - group: consul_group

consul_binary:
  archive.extracted:
    - name: /usr/local/bin
    - source: https://releases.hashicorp.com/consul/{{ consul.version }}/consul_{{ consul.version }}_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/consul/{{ consul.version }}/consul_{{ consul.version }}_SHA256SUMS
    - enforce_toplevel: False
    - if_missing: /usr/local/bin/consul

consul_data_dir:
  file.directory:
    - name: {{ consul.data_dir }}
    - user: {{ consul.user }}
    - group: {{ consul.group }}

consul_service_file:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: {{ consul.service_file }}
    - template: jinja
    - mode: 0640