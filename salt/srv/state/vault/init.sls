include:
  - .install
  - .configure

vault_is_initialized:
  vault.is_initialized:
    - secret_shares: 1
    - secret_threshold: 1