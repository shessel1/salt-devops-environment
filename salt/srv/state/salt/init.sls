{% set packages = salt.pillar.get("minion:packages", []) %}
{% set pip_packages = salt.pillar.get("minion:pip_packages", []) %}

minion_packages:
  pkg.installed:
    - pkgs: {{ packages }}

{% for package in pip_packages %}
minion_pip_package_{{ package }}:
  pip.installed:
    - name: {{ package }}
    - reload_modules: True
    - require:
      - pkg: minion_packages
{% endfor %}