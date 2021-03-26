#! /usr/bin/env python3

import csv
import ipaddress
import random

def mat2ipv6(matricula: str, ipv6_64: ipaddress.IPv6Address) -> ipaddress.IPv6Address:
    '''
    Converte matrícula para endereço IPv6
    '''

    if matricula.isdigit() and len(matricula) <= 14:
        # python - Decorating Hex function to pad zeros - Stack Overflow
        # https://stackoverflow.com/questions/12638408/decorating-hex-function-to-pad-zeros
        hexmat = '{0:#0{1}x}'.format(int(matricula), 14)[2:]
        g5,g6,g7 = hexmat[:4],hexmat[4:8],hexmat[8:]
        ipv6_grps = ipv6_64.exploded.split(':')
        ipv6_grps[4] = g5
        ipv6_grps[5] = g6
        ipv6_grps[6] = g7
        ipv6_grps[7] = '0000'

        return ipaddress.IPv6Address(':'.join(ipv6_grps))


def cria_conteiner(matricula: str, n_pc: int, ipv6_ini: ipaddress.IPv6Address):
    cmd1 = f'lxc launch images:ubuntu/20.04 pc-{n_pc}-{matricula}'
    netplan_tmpl = '''\
network:
  ethernets:
    eth0:
      addresses:
      - {end_ipv6}/64
      dhcp4: 'true'
  version: '2'
'''
    return cmd1


class DnsLab:
    def __init__(self, regrec: dict):
        self.email = regrec['email']
        self.matricula = regrec['matricula']
        self.nome = regrec['nome']
        self.zona = regrec['zona']
        self.a = [
            regrec['a1'],
            regrec['a2'],
            regrec['a3'],
            regrec['a4'],
            regrec['a5']
        ]
        # Assegure-se que os registros são únicos
        assert len(set(self.a)) == len(self.a)

        self.cname = {
            regrec['apelido1']: regrec['cname1'],
            regrec['apelido2']: regrec['cname2'],
            regrec['apelido3']: regrec['cname3'],
            regrec['apelido4']: regrec['cname4'],
            regrec['apelido5']: regrec['cname5'],
            regrec['apelido6']: regrec['cname6'],
        }
        # Assegure-se que todos os apelidos são para registros cadastrados
        for nome in self.cname.values():
            assert nome in self.a

        self.mx = {
            regrec['mx1']: regrec['pri.mx1'],
            regrec['mx2']: regrec['pri.mx2'],
        }
        # Assegure-se que os MXs são únicos
        chaves = list(self.mx.keys())
        assert chaves[0] != chaves[1]

        # Assegure-se que os MXs pertencem aos As
        assert set(self.mx.keys()).issubset(set(self.a))

    def __repr__(self):
        return f'DnsLab: <{self.nome}>'


def carrega_rrs():
    leitor = csv.DictReader(open('dnslab.csv'))
    mat2reg = {}
    for linha in leitor:
        registro = DnsLab(linha)
        mat2reg[registro.matricula] = registro

    return mat2reg


SMB_DNS = 'sudo samba-tool dns'
SMB_USR_PSS = '-U Administrator%Ifrn.2021'

def dados2smbtl(dados: DnsLab) -> str:
    lxdbr0 = ipaddress.IPv6Address('fd42:fcba:e07d:cd95::1')
    ipv6base = mat2ipv6(dados.matricula, lxdbr0)

    zona = dados.zona
    sub_cmds = [f'zonecreate localhost {zona}.']

    for i,nome in enumerate(dados.a, start=1): # É uma lista
        ip = ipv6base+(1000*6+random.randint(1, 50))
        sub_cmds.append(f'add localhost {zona}. {nome}.{zona}. AAAA {ip}')

    for i,nome in enumerate(['ns1', 'ns2'], start=7): # É uma lista
        ip = ipv6base+(1000*6+random.randint(1, 50))
        sub_cmds.append(f'add localhost {zona}. {nome}.{zona}. AAAA {ip}')
        sub_cmds.append(f"add localhost {zona}. {nome}.{zona}. NS {zona}.")

    for apelido,nome in dados.cname.items(): #  É um dicionário
        sub_cmds.append(f'add localhost {zona}. {apelido}.{zona}. CNAME {nome}.{zona}.')        

    for mx,prior in dados.mx.items(): #  É um dicionário
        sub_cmds.append(f'add localhost {zona}. @ MX "{nome}.{zona}. {prior}"')

    comandos = [f'{SMB_DNS} {sub} {SMB_USR_PSS}' for sub in sub_cmds]

    return '\n'.join(comandos)

def main():
    pass

if __name__ == '__main__':
    main()    

mat2reg = carrega_rrs()
for mat,reg in mat2reg.items():
    with open(f'scripts/{mat}.sh', 'w') as arq:
        arq.write(dados2smbtl(reg))
