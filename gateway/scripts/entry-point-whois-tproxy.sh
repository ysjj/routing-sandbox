#!/bin/bash

nft -f - <<EOF
table ip filter {
	chain whois_transparent_proxy {
		type nat hook prerouting priority filter;
		ip saddr 192.168.1.0/24 tcp dport 43 redirect to :8043;
	}
}
EOF

while true; do /root/scripts/whois-tproxy.sh; done &
