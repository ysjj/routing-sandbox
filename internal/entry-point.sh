#!/bin/bash

ip route add default via 192.168.1.250

cp /etc/resolv.conf /tmp/resolv.conf
sed -i -e 's/nameserver .*/nameserver 192.168.1.250/' /tmp/resolv.conf
cp -p /etc/resolv.conf /etc/resolv.conf.bak
cp /tmp/resolv.conf /etc/resolv.conf
rm /tmp/resolv.conf

exec "$@"
