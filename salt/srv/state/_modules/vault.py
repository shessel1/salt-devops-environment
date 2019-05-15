import os
import pathlib
import functools
import logging

import hvac
import hvac.api

import salt.utils
import salt.exceptions

__virtualname__ = 'vault'

logger = logging.getLogger(__name__)

def __init__(opts):
  _bind_methods()

def _get_attrs(type):
  return [m for m in dir(type) if not m.startswith("_")]

def _get_token(token_file):
  if os.path.exists(token_file) and os.path.getsize(token_file) > 0:
    return pathlib.Path(token_file).read_text()
  else:
    return None

def _bind_method(path):
  def bound(*args, **kwargs):
    kwargs = salt.utils.args.clean_kwargs(**kwargs)
    conn_options = __salt__["config.get"]("vault:conn", {})
    auth_options = __salt__["config.get"]("vault:auth", {})
    for k, v in kwargs.items():
      if isinstance(v, str) and v.startswith("conn_"):
        kwargs.pop(k)
        conn_options[k] = v[len("conn_"):]
    token = auth_options.get("token", None)
    token_file = auth_options.get("token_file", None)
    if token is not None:
      conn_options["token"] = token
    elif token_file is not None:
      conn_options["token"] = _get_token(token_file)
    client = hvac.Client(**conn_options)
    return functools.reduce(getattr, path.split("."), client)(*args, **kwargs)
  return bound

def _bind_methods():
  for attr in _get_attrs(hvac.Client):
    backends = {
      "sys": hvac.api.SystemBackend,
      "secret": hvac.api.SecretsEngines,
      "auth": hvac.api.AuthMethods
    }
    if attr in backends:
      for backend_attr in _get_attrs(backends[attr]):
        name, path = (attr + delim + backend_attr for delim in ["_", "."])
        globals()[name] = _bind_method(path)
    else:
      globals()[attr] = _bind_method(attr)
