#!/bin/bash
# A exportação foi feita na máquina antiga com os comandos:
# pwunconv; 
# grep -E '^(colega1|colega2|colega3):' /etc/passwd > /tmp/colegas; 
# pwconv; 
# scp /tmp/colegas {maq-nova}:/tmp/colegas

$ while IFS=: read user pass uid gid gecos _; do
  sudo useradd -m -c "$gecos" -s /bin/bash "$user"; sudo usermod -p "$pass" $user     
done < /tmp/colegas
