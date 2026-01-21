#!/bin/bash
set -euo pipefail

SECRET_PATH="${1:?missing secret path}"

if vault kv get -mount=cbi -field=password "$SECRET_PATH" >/dev/null 2>&1; then
  PASSWORD="$(vault kv get -mount=cbi -field=password "$SECRET_PATH" 2>/dev/null)"
  printf '{"exists":"true","password":"%s"}\n' "$PASSWORD"
else
  printf '{"exists":"false","password":""}\n'
fi
