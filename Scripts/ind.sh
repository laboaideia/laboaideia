#!/usr/bin/bash

# Os endereços IPês foram fixados via script[1] baseados em uma faixa de endereços IPv4 
# não distribuídos pelo servidor DHCP do campus e ainda assim pertencente à faixa de 
# endereços IPv4 disponibilizada para os laboratórios de informática do campus 
# ({NET_ID}.0.0/16). Seguiu-se o modelo: <{NET_ID}.{SALA}.{PC}<, onde <{SALA}> é o número 
# da sala (lab. 01, sala 48; lab 02, sala 51 etc.) e <{PC}> é o número do PC dentro do laboratório.
#

if [ "$#" -ne 2 ]; then
    echo "Uso: ${0} LAB PC"
    exit 1
fi

#ADMIN="administrator"
DOMINIO="ifpar.lab"
DNS1="10.214.0.155"
CAMPUS="par"
IFACE=$(ip -br link | awk '($1 ~ /^e/){print $1}' | head -1)
LAB="$1"
NET_ID="10.209.48"
HOST_ID="$2"
IP="${NET_ID}.${HOST_ID}"
GATEWAY="${NET_ID}.1"  # Propenso a erro
PCP=`printf %02d ${HOST_ID}` # Preenchimento com 0 à esquerda, quando necessário

MAC=$(ip -br link show dev ${IFACE} | awk '{print $3}')


echo "Por gentileza, se autentique com sudo."
sudo -v

new_hostname="pc-${PCP}-lab${LAB}${CAMPUS}"

cat << EOF | sudo tee /etc/hosts
127.0.0.1	localhost
127.0.1.1	${new_hostname}

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
      addresses: [${IP}/16]
      gateway4: ${GATEWWAY}
      nameservers:
        search: 
            - ${DOMINIO}
        addresses:
            - ${DNS1}
      
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

wget -O /dev/null https://oulu.ifrn.edu.br/lab/01/${IP}/${MAC}/
sudo etckeeper commit "Pos-clonagem: end. IP fixo"

# sudo realm join -U $ADMIN $DOMINIO

sudo systemctl poweroff

