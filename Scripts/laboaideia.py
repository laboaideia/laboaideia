#! /usr/bin/env python3

import ipaddress

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

lxdbr0 = ipaddress.IPv6Address('fd42:fcba:e07d:cd95::1')
print(mat2ipv6('1577142', lxdbr0))
