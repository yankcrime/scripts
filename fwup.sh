#!/bin/bash

# iptables for trillian.dischord.org
# nick@dischord.org - 19/06/2013
# last update for steam

echo "IPv4 Rules"
set -e

# FLUSH RULES
iptables -F
iptables -X
iptables -Z
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

# RP_FILTER
for f in /proc/sys/net/ipv4/conf/*
do
  echo 1 > $f/rp_filter
  echo 0 > $f/accept_source_route
  echo 0 > $f/accept_redirects
  echo 0 > $f/send_redirects
  echo 1 > $f/log_martians
done
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 0 > /proc/sys/net/ipv4/tcp_ecn
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1800 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 1800 > /proc/sys/net/ipv4/tcp_keepalive_time
echo 0 > /proc/sys/net/ipv4/tcp_window_scaling
echo 0 > /proc/sys/net/ipv4/tcp_sack
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/secure_redirects

# SET CHAIN DEFAULTS
iptables -P INPUT DROP 
iptables -P FORWARD DROP 
iptables -P OUTPUT ACCEPT

## BLIND ACCEPT LOCAL
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

## RETURN INPUT RULES
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

## TCP RULES
iptables -A INPUT -p tcp --dport 25 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A INPUT -p TCP --dport 80 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 5232 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 7020 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 7667 -m state --state NEW -j ACCEPT

## STEAM
iptables -A INPUT -p tcp --dport 17500 -m state --state NEW -j ACCEPT
iptables -A INPUT -p udp --dport 17500 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 27015 -m state --state NEW -j ACCEPT
iptables -A INPUT -p udp --dport 27015 -m state --state NEW -j ACCEPT
iptables -A INPUT -p udp --dport 27020 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 26901 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 26901 -m state --state NEW -j ACCEPT

## SSH 
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

## MOSH
iptables -A INPUT -p udp --dport 60000:61000 -m state --state NEW -j ACCEPT

## VPN
iptables --table nat --append POSTROUTING --jump MASQUERADE
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport l2tp -j ACCEPT
iptables -A FORWARD -i ppp0 -j ACCEPT
iptables -A FORWARD -o ppp0 -j ACCEPT

iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 10/min -j LOG --log-prefix "IPTables Dropped: " --log-level 4
iptables -A LOGGING -j DROP
