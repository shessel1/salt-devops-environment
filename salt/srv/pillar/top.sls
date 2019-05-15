base:
    '*':
      - salt
      - docker
      - consul
      - dnsmasq.consul
    'G@roles:master':
      - consul.server
      - vault