#!/bin/bash

cat <<EOF >/etc/nginx/modules-enabled/90-local-whois-gateway.conf
stream {
    server {
        listen 8043;
        proxy_pass whois.jprs.jp:43;
    }
    server {
        listen 8143;
        proxy_pass whois.nic.ad.jp:43;
    }
}
EOF

exec "$@"
