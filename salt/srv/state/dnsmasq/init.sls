dnsmasq_package:
  pkg.installed:
    - name: dnsmasq

networkmanager_dnsmasq_config:
  file.managed:
    - name: /etc/NetworkManager/conf.d/dnsmasq.conf
    - contents: |
        [main]
        dns=dnsmasq

{% for name, config in salt.pillar.get("dnsmasq:config", {}).items() %}
dnsmasq_config_{{ name }}:
  file.managed:
    - name: /etc/NetworkManager/dnsmasq.d/{{ name }}.conf
    - contents: {{ config | yaml_encode }}
    - makedirs: True
{% endfor %}

networkmanager_service:
  service.running:
    - name: NetworkManager
    - enable: True
    - reload: True
    - requires:
      - service: dnsmasq_service
    - watch:
      - file: networkmanager_dnsmasq_config