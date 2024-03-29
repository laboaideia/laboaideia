#!/usr/bin/env zsh

grupos=adm,cdrom,docker,sudo,dip,plugdev,lpadmin,lxd,sambashare,wireshark
arquivos=(group passwd shadow)
nao_encontrado=false

for arq in ${arquivos[@]}; do
    if [ ! -e "${arq}" ]; then
        echo "O arquivo ${arq} não foi encontrado."
        nao_encontrado=true
    fi
done

if $nao_encontrado; then
    echo "Este script deve ser executado em um backup do diretório /etc."
    exit 2
fi

professores=($(grep professor group | cut -d: -f5 | sed 's/,/ /g'))
print -l $professores

for prof in ${professores[@]}; do
    gecos="$(grep -E "^${prof}:" passwd | cut -d: -f6)"
    sudo useradd -m -b /home/professor -s /bin/zsh -c "${gecos}" "${prof}"
    echo "${prof}:${password}" | sudo chpasswd -e
    sudo usermod -aG "${grupos}" "${prof}"
done < shadow
