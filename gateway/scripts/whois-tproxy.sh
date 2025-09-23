#!/bin/bash

exec socat tcp4-listen:8043,fork,reuseaddr,bind=192.168.1.250,ip-transparent exec:/root/scripts/whois-tproxy.pl,nofork
