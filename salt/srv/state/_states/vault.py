import pathlib

import salt.exceptions

__virtualname__ = "vault"

def is_initialized(name, unseal=True, **kwargs):
  ret = {
    "name": name,
    "changes": {},
    "result": True,
    "comment": "",
  }
  new = {}
  if __salt__["vault.sys_is_initialized"]():
    ret["comment"] = "The Vault instance is already initialized"
  else:
    response = __salt__["vault.sys_initialize"](**kwargs)
    token_file = __salt__["config.get"]("vault:auth:token_file", None)
    if token_file is not None:
      pathlib.Path(token_file).write_text(response["root_token"])
    new["initialize"] = response
    if unseal:
      unseal_response = __salt__["vault.sys_unseal_multi"](response["keys"])
      new["unseal"] = unseal_response
    ret["changes"] = {
      "old": {},
      "new": new
    }
  return ret

def is_unsealed(name, unseal_keys=None):
  ret = {
    "name": name,
    "changes": {},
    "result": True,
    "comment": "",
  }
  status = __salt__["vault.sys_read_seal_status"]()
  if not status.sealed:
    ret["comment"] = "The Vault instance is already unsealed"
  else:
    response = __salt__["vault.sys_submit_unseal_keys"](unseal_keys)
    ret["changes"] = {
      "old": status,
      "new": response
    }
  return ret

def secret_engine_enabled(name, path=None, backend_type=None, **kwargs):
  ret = {
    "name": name,
    "changes": {},
    "result": True,
    "comment": "",
  }
  engines = __salt__["vault.sys_list_mounted_secrets_engines"]()["data"]
  if not path.endswith("/"):
    path += "/"
  if path in engines:
    if engines[path]["type"] == backend_type:
      ret["comment"] = "The secret engine {} is already mounted at path {}" \
        .format(backend_type, path)
    else:
      ret["result"] = False
      ret["comment"] = "A secret engine with different type {} is already mounted at path {}" \
        .format(engines[path]["type"], path)
  else:
    response = __salt__["vault.sys_enable_secrets_engine"]
    ret["changes"] = {
      "old": {},
      "new": response
    }
  return ret

def auth_method_enabled(name, path=None, method_type=None, **kwargs):
  ret = {
    "name": name,
    "changes": {},
    "result": True,
    "comment": "",
  }
  auth_methods = __salt__["vault.sys_list_auth_methods"]()["data"]
  if not path.endswith("/"):
    path += "/"
  if path in auth_methods:
    if auth_methods[path]["type"] == method_type:
      ret["comment"] = "The auth method {} is already mounted at path {}" \
        .format(method_type, path)
    else:
      ret["result"] = False
      ret["comment"] = "An auth method with different type {} is already mounted at path {}" \
        .format(auth_methods[path]["type"], path)
  else:
    response = __salt__["vault.sys_enable_auth_method"]
    ret["changes"] = {
      "old": {},
      "new": response
    }
  return ret
