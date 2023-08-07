#!/bin/bash

# Cria uma conta para cada uma das turmas do campus
contas=($(echo info{1..4}{m,v} meca{1..4}{m,n,v} redes{1..4} tsi{1..6}))

for usuario in ${contas[@]}
do
  echo "Criação de conta para ${usuario^}"
  sudo useradd -m -s /bin/bash -c "${usuario^}" $usuario
  
  echo "Troca da senha para ${usuario}"
  echo "${usuario}:${usuario}" | sudo chpasswd
  
  echo "Forçando a troca de senha na primeira sessão."
  sudo chage -d 0 ${usuario}  
done
