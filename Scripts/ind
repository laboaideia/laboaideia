#!/usr/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: ${0} NUM_PC"
    exit 1
fi

echo $*

#ADMIN="administrator"
#DOMINIO="ifrn.local"
PC=`printf %02d $1`
HOSTID=$1


MAC=$(ip -br link show dev eno1 | awk '{print $3}')
IP="10.209.48.${HOSTID}"

echo "Por gentileza, se autentique com sudo."
sudo -v

new_hostname="pc-${PC}-lab01par"

cat << EOF | sudo tee /etc/hosts
127.0.0.1	localhost
127.0.1.1	${new_hostname}
10.214.0.155	parola.ifrn.local	parola


# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

cat << EOF | sudo tee /etc/netplan/01-network-manager-all.yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      addresses: [10.209.48.${HOSTID}/16]
      gateway4: 10.209.0.1
      nameservers:
        search: 
            - ifrn.local
        addresses:
            - 10.214.0.155
      
EOF

cat << EOF | sudo tee /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the \`glibc-doc-reference' and \`info' packages installed, try:
# \`info libc "Name Service Switch"' for information about this file.

passwd:         files systemd
group:          files systemd
shadow:         files
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
sudoers:        files sss
EOF

sudo netplan apply

sudo hostnamectl set-hostname ${new_hostname}

wget https://oulu.ifrn.edu.br/lab/01/${IP}/${MAC}
sudo etckeeper commit "Pos-clonagem: end. IP fixo"

# sudo realm join -U $ADMIN $DOMINIO

sudo systemctl poweroff

