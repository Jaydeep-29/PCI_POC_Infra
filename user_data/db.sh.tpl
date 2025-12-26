#!/bin/bash
set -euo pipefail

echo "[bootstrap] db: start"

yum update -y
yum install -y mariadb105-server openssl

systemctl enable mariadb
systemctl start mariadb

# Generate password locally, not from Terraform
MYSQL_ROOT_PASSWORD="$(openssl rand -base64 24)"

mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EOF

echo "[bootstrap] db: root password set (not logged for security)"
echo "[bootstrap] db: done"
