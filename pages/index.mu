#!/usr/bin/python3
import subprocess
import os

# --- Connect ---
print('> `!Connect to this Node`!')
print()

host = os.environ.get('PEP_TCP_HOST', 'YOUR.HOST.OR.IP.HERE')
port = os.environ.get('PEP_TCP_PORT', '4242')

print('Connect your client (Columba/Sideband/MeshchatX) or add to `~/.reticulum/config`:')
print('`=')
#--- TODO replace the RANDOM belom using the docker entrypoint method that does this for the other templates.
print('[[RNS-PEP-RANDOM]]')
print('    type = TCPClientInterface')
print('    interface_enabled = true')
print('    target_host = ' + host)
print('    target_port = ' + port)
print('`=')
print('(This node runs a BackboneInterface internally. Clients connect via TCPClientInterface as shown above.)')
print()

# --- Uptime ---
print('> `!Uptime`!')
print()
try:
    with open('/proc/uptime', 'r') as f:
        secs = float(f.read().split()[0])
    days = int(secs // 86400)
    hours = int((secs % 86400) // 3600)
    mins = int((secs % 3600) // 60)
    print(f'up {days} days, {hours:02d}:{mins:02d}')
except Exception as e:
    print('uptime unavailable: ' + str(e))
print()

# --- Software Versions ---
print('> `!Software Versions`!')
print()
print(subprocess.getoutput('/opt/venv/bin/rnsd --version'))
print(subprocess.getoutput('/opt/venv/bin/lxmd --version'))

rns_page_node_info = subprocess.getoutput('/opt/venv/bin/pip show rns-page-node')
ver_line = next((l for l in rns_page_node_info.splitlines() if l.startswith('Version:')), None)
if ver_line:
    print('rns-page-node ' + ver_line.split(':', 1)[1].strip())
else:
    print('rns-page-node (version unknown)')
print()

# --- LXMF Propagation Node ---
print('> `!LXMF Propagation Node`!')
print('`=')
print(subprocess.getoutput('/opt/venv/bin/lxmd --status --config /rns-pep/lxmd'))
print('`=')

# --- Transport Node Status ---
print('> `!Reticulum Transport Node Status`!')
print('`=')
print(subprocess.getoutput('/opt/venv/bin/rnstatus --config /rns-pep'))
print('`=')
