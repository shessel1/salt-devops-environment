vault:
  install:
    version: 1.1.2
    user: vault
    group: vault
    config_file: /etc/vault.d/server.json
    service_file: salt://vault/files/vault.service
  conn:
    url: http://127.0.0.1:8200
    verify: False
  config:
    ui: true
    listener:
      tcp:
        address: 0.0.0.0:8200
        tls_disable: 1
    storage:
      consul:
        address: consul.service.consul:8500
        path: vault