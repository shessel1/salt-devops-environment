private_subnet_cidr: 10.0.0.0/24

mine_functions:
  internal_ip:
    mine_function: network.ip_addrs
    cidr: 10.0.0.0/24

minion:
  packages:
    - python36-pip