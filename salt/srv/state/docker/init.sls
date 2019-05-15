{% set config = salt.pillar.get("docker:daemon", {}) %}
{% set service_file = salt.pillar.get("docker:service", None) %}

docker_dependencies:
  pip.installed:
    - name: docker
    - reload_modules: True

docker_repo:
  pkgrepo.managed:
    - name: docker-ce
    - humanname: Official Docker CE Repository
    - baseurl: https://download.docker.com/linux/centos/7/$basearch/stable
    - gpgkey: https://download.docker.com/linux/centos/gpg

docker_package:
  pkg.installed:
    - name: docker-ce
    - refresh: True
    - require:
      - pkgrepo: docker_repo

docker_daemon_config:
    file.serialize:
      - name: /etc/docker/daemon.json
      - formatter: json
      - dataset: {{ config | json }}
      - makedirs: True
  
{% if service_file != None %}
docker_service_file:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: {{ service_file }}
{% endif %}

docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_package
    - watch:
      - file: docker_daemon_config
{% if service_file != None %}
      - file: docker_service_file
{% endif %}