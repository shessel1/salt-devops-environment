{% from './init.sls' import nodes %}

consul:
  server: true
  config:
    server:
      ui: true
      server: true
      addresses:
        http: 0.0.0.0
      ports:
        http: 8500
      bootstrap_expect: {{ ( nodes | length ) + 1 }}