#!/bin/bash

# URL to register the update
URL="https://oulu.ifrn.edu.br/update/lab/redes/"

# Date and time
DATE=$(date +%F)
TIME=$(date +%T)

# First ethernet interface
ENET=$(ip -br link | awk '($1 ~ /^e/){print $1}' | head -1)

# First IPv4 address of first ethernet interface
IP=$(ip -4 -br address show dev $ENET | awk '{print $3}' | cut -d/ -f1)

# Update URL
UP_URL="${URL}/${IP}/${DATE}/${TIME}/"

apt update
apt upgrade -y

wget -O /dev/null "${UP_URL}"

systemctl reboot
