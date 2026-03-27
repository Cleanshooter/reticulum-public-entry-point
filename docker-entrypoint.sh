#!/bin/sh
set -e


CONFIG_DIR="/home/rnsuser/.reticulum"
CONFIG_FILE="$CONFIG_DIR/config"


# Ensure config dir exists and is writable by rnsuser
mkdir -p "$CONFIG_DIR"
chown -R rnsuser:rnsuser "$CONFIG_DIR" || true

# Generate config from template if it does not exist
TEMPLATE_FILE="/home/rnsuser/reticulum-config.template"
LOCAL_TEMPLATE="/reticulum-config.template"
if [ ! -f "$CONFIG_FILE" ]; then
  if [ -f "$TEMPLATE_FILE" ]; then
    cp "$TEMPLATE_FILE" "$CONFIG_FILE"
  elif [ -f "$LOCAL_TEMPLATE" ]; then
    cp "$LOCAL_TEMPLATE" "$CONFIG_FILE"
  else
    echo "Error: No config template found!" >&2
    exit 1
  fi
  chown rnsuser:rnsuser "$CONFIG_FILE"
fi

# If first arg starts with '-', prepend rnsd
# If no args provided, default to running rnsd (non-service mode).
if [ "$#" -eq 0 ]; then
  set -- rnsd
fi

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
