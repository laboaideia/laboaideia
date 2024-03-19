# ---------------------------------------------------------------
# Nome do Script: mapecode.ps1
# Autor: Jurandy Soares
# Data: 15/03/2024
# Descrição: Script para mapear caminho UNC e abrir VS Code
# Versão: 1.0
# Observações: Este script é apenas para fins educacionais.
# ---------------------------------------------------------------

# Adaptado de: https://manueltgomes.com/microsoft/powershell/how-to-replace-accents-in-strings/
function Slugify-Texto {
    # From https://stackoverflow.com/questions/7836670/how-remove-accents-in-powershell
    param ([String]$sourceStringToClean = [String]::Empty)
    $normalizedString = $sourceStringToClean.Normalize( [Text.NormalizationForm]::FormD )
    $stringBuilder = new-object Text.StringBuilder
    $normalizedString.ToCharArray() | ForEach-Object {
        if ( [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$stringBuilder.Append($_)
        }
    }
    # From https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
    $texto_sem_acento = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($stringBuilder.ToString()))
    $texto_sem_acento.ToLower().Replace(' ', '-')
}

# Cria uma constante para guardar o nome do servidor
Set-Variable -Name NOME_SERVIDOR -Value "PAR156008" -Option Constant

# Cria uma constante para guardar a abreviação da disciplina
Set-Variable -Name ABR_DISC -Value "gsi-2024-1" -Option Constant

# Remove o drive P se ele existir para evitar erros ao criá-lo novamente
Remove-PSDrive -Name "P" -ErrorAction SilentlyContinue

# Recupera nome do computador, domínio e nome de usuário das variáveis de ambiente
$nomeComputador = $env:COMPUTERNAME
$dominio = $env:USERDOMAIN
$usuario = $env:USERNAME

# Obtenção da rota padrão IPv4
$rota_padrao_ipv4 = Get-NetRoute -AddressFamily IPv4 | Where-Object {$_.DestinationPrefix -eq '0.0.0.0/0'}

# End. IPv4 da interface com conexão à Internet
$end_ipv4 = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceIndex -eq $rota_padrao_ipv4.ifIndex}

# Obtém a data atual no formato aaaa-MM-dd
$data = Get-Date -Format "yyyy-MM-dd"

# Obtém o nome completo do usuário do Active Directory
$nomeCompleto = ([adsi]"WinNT://$dominio/$usuario,user").fullname[0]

# Divide o nome completo em primeiro nome e sobrenome
$priNomeCru, $sobrenome = $nomeCompleto.Split(" ", 2)
$priLetra = $priNomeCru.ToUpper()[0]
$outrasLetras = $priNomeCru.ToLower().Substring(1, $priNome.Length-1)
$priNome = "${priLetra}${outrasLetras}"

# Limpa o terminal
Clear-Host

# Obtém a hora atual para depois escolher a saudação apropriada
$hora = (Get-Date).Hour
$saudacao = if ($hora -ge 0 -and $hora -lt 12) { "Bom dia" } `
            elseif ($hora -ge 12 -and $hora -lt 18) { "Boa tarde" } `
            else { "Boa noite" }

Write-Host "${saudacao}, ${priNome}!"

# Solicita ao usuário o número do seu PC
Write-Host "Por gentileza, levante-se e procure a etiqueta que tem o numero de seu PC."

$numeroPC = Read-Host -Prompt "Qual eh o numero de seu PC"
while (!($numero -match '^[0-9]+') -or ([int]$numeroPC -lt 1) -or ([int]$numeroPC -gt 30)) {
        $numeroPC = Read-Host -Prompt "Qual eh o numero de seu PC"
}

# Nome do compartilhamento que depende do número do PC
#$shName = If (([int]$numeroPC % 2) -eq 0) { "tico" } Else { "teco" }

# Cria um novo drive P mapeado para o caminho de rede especificado, usando a variável de data atual
if (!(Test-Path -Path "P:" -PathType Container)) {
    $p = New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\${NOME_SERVIDOR}\${ABR_DISC}\aulas\aula-$data" -Persist
}

if ((Test-Path -Path "P:" -PathType Container)) {

    # Altera o local atual para o drive P
    Set-Location "P:"

    # Registra a presença
    Set-Location "lista-de-presenca"
    $presencao = @{
        matricula = $usuario
        nome = $nomeCompleto
        horario = Get-Date -UFormat "%F_%T"
    }

    # Cria um arquivo para registrar presença
    $marcaTempo = Get-Date -UFormat "%Y%m%dT%H%M%S"
    $nomeArq = "${marcaTempo}-${priNome}-${usuario}.json"
    $presenca | Out-File -Name $nomeArq

    Set-Location "P:"

    # Cria um nome de diretório usando o número do PC e o primeiro nome, preenchendo o número do PC com zeros à esquerda
    $slugPriNome = Slugify-Text($priNome)
    $nomeDir = "PC-$($numeroPC.PadLeft(2, '0'))-$slugPriNome"

    # Cria o novo diretório caso ainda não exista
    # if (!(Test-Path -PathType Container $nomeDir)) {
    New-Item -ItemType Directory -Path $nomeDir
    # }


    # Altera o local para o novo diretório
    Set-Location $nomeDir

    # Cria um arquivo JSON com dados do estudante e do computador
    $estudante = @{
        matricula = $usuario
        nome = $nomeCompleto
        slug_nome = Slugify-Text($nomeCompleto)
    }
    $computador = @{
        nome = $nomeComputador
        numero = $numeroPC
        ipv4 = $end_ipv4.IPAddress + "/" + $end_ipv4.PrefixLength
    }

    $dados = @{
        estudante = $estudante
        computador = $computador
    }

    $dados | ConvertTo-Json | Out-File "dados.json"

    # Abre o diretório atual no Visual Studio Code
    code .

}
