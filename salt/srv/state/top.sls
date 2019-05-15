base:
  '*':
    - salt
    - docker
    - consul
    - dnsmasq
  'G@roles:master':
    - vault