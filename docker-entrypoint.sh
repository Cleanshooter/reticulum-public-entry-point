#!/bin/sh
set -e


# Ensure rns-pep config/data directory and subfolders
PEP_DIR="/rns-pep"
mkdir -p "$PEP_DIR" "$PEP_DIR/lxmd" "$PEP_DIR/node-config" "$PEP_DIR/pages" "$PEP_DIR/files"

# Generate a single SUFFIX for all configs (3 random bytes as hex)
SUFFIX=${SUFFIX:-$(hexdump -n 3 -e '3/1 "%02X"' /dev/urandom)}

# Reticulum config
RETICULUM_CONFIG="$PEP_DIR/config"
RETICULUM_TEMPLATE="$PEP_DIR/reticulum-config.template"
if [ ! -f "$RETICULUM_CONFIG" ] && [ -f "$RETICULUM_TEMPLATE" ]; then
  cp "$RETICULUM_TEMPLATE" "$RETICULUM_CONFIG"
fi

# LXMF config
LXMF_CONFIG="$PEP_DIR/lxmd/config"
LXMF_TEMPLATE="$PEP_DIR/lxmd-config.template"
if [ ! -f "$LXMF_CONFIG" ] && [ -f "$LXMF_TEMPLATE" ]; then
  awk -v suffix="$SUFFIX" '{
    if ($0 ~ /^display_name[ ]*=/) {
      print "display_name = RNS-PEP-" suffix
    } else {
      print $0
    }
  }' "$LXMF_TEMPLATE" > "$LXMF_CONFIG"
fi

# rns-page-node config (always create from template, no existence check needed)
RNS_PAGE_NODE_CONFIG="$PEP_DIR/rns-page-node.conf"
RNS_PAGE_NODE_TEMPLATE="$PEP_DIR/rns-page-node-config.template"
if [ ! -f "$RNS_PAGE_NODE_CONFIG" ]; then
  awk -v suffix="$SUFFIX" '{
    if ($0 ~ /^node-name[ ]*=/) {
      print "node-name=RNS-PEP-" suffix
    } else {
      print $0
    }
  }' "$RNS_PAGE_NODE_TEMPLATE" > "$RNS_PAGE_NODE_CONFIG"
fi

exec "$@"
