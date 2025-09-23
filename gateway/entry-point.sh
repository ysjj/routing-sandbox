#!/bin/bash

nft -f /etc/nftables.conf
nft -f - <<EOF
table ip filter {
	chain internal_dnat_dns {
		type nat hook prerouting priority filter;
		ip saddr 192.168.1.0/24 tcp dport 53 dnat to 172.16.1.1;
		ip saddr 192.168.1.0/24 udp dport 53 dnat to 172.16.1.1;
	}
    chain internal_snat {
		type nat hook postrouting priority filter;
		ip saddr 192.168.1.0/24 snat to 172.16.1.250;
	}
}
EOF

for script in /root/scripts/entry-point-*.sh; do $script; done

exec "$@"
