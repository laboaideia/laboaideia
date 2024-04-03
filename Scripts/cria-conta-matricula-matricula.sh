#!/bin/sh
# Cria contas com usuário/senha igual a matrícula dos estudantes.
# A conta "original" está no formato:
#   <nome.sobrenome>:<senha>:<uid>:<gid>:<nome completo>,<matrícula>:<home>:<shell>
#
CONTAS_MATMAT_2024="contas-mat-mat-2024.csv"

grep ",2024" /etc/passwd | \
     awk \
     -F'[:,]' \
     '{print $6":"$6":"$3":"$4":"$5","$1":"$7":"$8}' > "${CONTAS_MATMAT_2024}"

newusers "${CONTAS_MATMAT_2024}"
