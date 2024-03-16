# ---------------------------------------------------------------
# Nome do Script: mapecode.ps1
# Autor: Jurandy Soares
# Data: 15/03/2024
# Descrição: Script para mapear caminho UNC e abrir VS Code
# Versão: 1.0
# Observações: Este script é apenas para fins educacionais.
# ---------------------------------------------------------------

# Cria uma constante para guardar o nome do servidor
Set-Variable -Name NOME_SERVIDOR -Value "PAR406756" -Option Constant

# Cria uma constante para guardar a abreviação da disciplina
Set-Variable -Name ABR_DISC -Value "alg-2024-m" -Option Constant

# Remove o drive P se ele existir para evitar erros ao criá-lo novamente
Remove-PSDrive -Name "P" -ErrorAction SilentlyContinue

Write-Host "Será que foi antes ou depois?"
# Recupera nome do computador, domínio e nome de usuário das variáveis de ambiente
$nomeComputador = $env:COMPUTERNAME
$dominio = $env:USERDOMAIN
$usuario = $env:USERNAME

# Obtém a data atual no formato aaaa-MM-dd
$data = Get-Date -Format "yyyy-MM-dd"

# Obtém o nome completo do usuário do Active Directory
$nomeCompleto = ([adsi]"WinNT://$dominio/$usuario,user").fullname

# Divide o nome completo em primeiro nome e sobrenome
$priNome, $sobrenome = $nomeCompleto.Split(" ", 2)

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

# Cria um novo drive P mapeado para o caminho de rede especificado, usando a variável de data atual
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\${NOME_SERVIDOR}\${ABR_DISC}\aulas\aula-$data" -Persist

# Altera o local atual para o drive P
Set-Location "P:"

# Cria um nome de diretório usando o número do PC e o primeiro nome, preenchendo o número do PC com zeros à esquerda
$nomeDir = "PC-$($numeroPC.PadLeft(2, '0'))-$priNome"

# Cria o novo diretório caso ainda não exista
# if (!(Test-Path -PathType Container $nomeDir)) {
New-Item -ItemType Directory -Path $nomeDir
# }


# Altera o local para o novo diretório
Set-Location $nomeDir

# Cria um arquivo YAML com o número de matrícula do usuário e o nome completo
"matricula: $usuario" | Set-Content "dados.yaml"
"nome: $nomeCompleto" | Add-Content "dados.yaml"
"computador: $nomeComputador" | Add-Content "dados.yaml"

# Abre o diretório atual no Visual Studio Code
code .
