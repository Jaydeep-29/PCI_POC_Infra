#!/bin/bash
set -euo pipefail

yum update -y
yum install -y python3

# Application depends on package from example.com – if this fails, app must not start
echo "[bootstrap] downloading required package from example.com"
if ! curl -fsSL https://example.com/ -o /tmp/app-package.bin; then
  echo "[bootstrap] ERROR: failed to download required package from example.com" >&2
  exit 1
fi

# Simulate daily call to secureweb.com over HTTPS (e.g., for tokenization/settlement)
echo "[bootstrap] contacting secureweb.com"
curl -fsS https://secureweb.com/ >/var/log/secureweb-call.log || echo "[bootstrap] warning: secureweb.com call failed" >&2

cat >/usr/local/bin/pci-poc-app <<'EOF'
#!/bin/bash
cd /tmp
python3 -m http.server 80
EOF

chmod +x /usr/local/bin/pci-poc-app
nohup /usr/local/bin/pci-poc-app >/var/log/pci-poc-app.log 2>&1 &
