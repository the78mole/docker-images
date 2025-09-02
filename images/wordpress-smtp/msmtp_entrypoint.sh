#!/bin/bash

# Write msmtp config from ENV
cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        default
host           ${SMTP_HOST:-smtp.example.com}
port           ${SMTP_PORT:-587}
from           ${SMTP_FROM:-wordpress@example.com}
user           ${SMTP_USER:-user@example.com}
password       ${SMTP_PASS:-password}
EOF

chmod 600 /etc/msmtprc

# Link sendmail to msmtp
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Execute original WordPress entrypoint
exec "$@"