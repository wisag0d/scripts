#!/bin/sh
export OUTSIDE_INTERFACE="$(ip route | grep -e '^default' | sed -n -e 's/^.*dev //p' | awk '{print $1}')"
export IPADDR="192.168.100"

# ---
# Kernel parameters setup
sudo sysctl net.ipv4.ip_forward=1
echo -e "--> \e[32mTrun on\e[39m kernel parameters 'net.ipv4.ip_forward'"

# ---
# Setup the iptables rule.
if ! sudo iptables -t nat -C POSTROUTING -s "${IPADDR}.0/24" -o ${OUTSIDE_INTERFACE} -j MASQUERADE; then
  sudo iptables -t nat -A POSTROUTING -s "${IPADDR}.0/24" -o ${OUTSIDE_INTERFACE} -j MASQUERADE
  echo -e "--> \e[32mSetup\e[39m iptables NAT Postrouting 'net.ipv4.ip_forward'"
else
  echo -e "--> \e[33mAlready setup\e[39m iptables NAT Postrouting 'net.ipv4.ip_forward'"
fi

# ---
# Start DNSMASQ on foreground
sudo dnsmasq --no-daemon --log-queries \
  --interface=br0 \
  --dhcp-range=${IPADDR}.100,${IPADDR}.200,12h \
  --dhcp-option=3,${IPADDR}.254 \
  --dhcp-option=6,8.8.8.8 \
  --no-resolv \
  --server=8.8.8.8

# ---
# Kernel parameters close
sudo sysctl net.ipv4.ip_forward=0
echo -e "--> \e[31mTrun off\e[39m Kernel parameters 'net.ipv4.ip_forward'"

# ---
# Delete the iptables rule
sudo iptables -t nat -D POSTROUTING -s "${IPADDR}.0/24" -o ${OUTSIDE_INTERFACE} -j MASQUERADE
echo -e "--> \e[31mDelete\e[39m iptables NAT Postrouting 'net.ipv4.ip_forward'"
