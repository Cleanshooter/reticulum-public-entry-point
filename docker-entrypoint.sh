#!/bin/sh
set -e

CONFIG_DIR="/home/rnsuser/.reticulum"

# Ensure config dir exists and is writable by rnsuser
mkdir -p "$CONFIG_DIR"
chown -R rnsuser:rnsuser "$CONFIG_DIR" || true

# If first arg starts with '-', prepend rnsd
if [ "${1#-}" != "$1" ]; then
  set -- rnsd "$@"
fi

# If command is rnsd, run it as rnsuser. Prefer runuser, fall back to su.
if [ "$1" = "rnsd" ]; then
  if command -v runuser >/dev/null 2>&1; then
    exec runuser -u rnsuser -- "$@"
  else
    exec su -s /bin/sh rnsuser -c "$*"
  fi
fi

# Otherwise exec the given command as-is
exec "$@"
