{% set private_subnet_cidr = salt.pillar.get("private_subnet_cidr") %}
{% set local_ip = salt.network.ipaddrs(cidr=private_subnet_cidr)[0] %}
{% set nodes = [] %}
{% for host, addr in salt.saltutil.runner('mine.get',
    tgt='I@consul:server:*',
    fun='internal_ip',
    tgt_type='compound').items() if addr[0] != local_ip %}
{%  do nodes.append(addr[0]) %}
{% endfor %}

consul:
  install:
    version: 1.5.0
    service_file: salt://consul/files/consul.service
    config_dir: /etc/consul
    data_dir: /opt/consul
    user: consul
    group: consul
  config:
    common:
      bind_addr: 0.0.0.0
      advertise_addr: {{ local_ip }}
      data_dir: /opt/consul
      retry_join: {{ nodes }}

minion:
  pip_packages:
    - hvac