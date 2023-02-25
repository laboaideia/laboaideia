if ($args.Length -eq 1) {
   $arq_pacotes = $args[0]
   if (Test-Path -Path $arq_pacotes -PathType Leaf) {
      Import-Csv -Path $arq_pacotes -Header Pacote | ForEach-Object {
         $pacote = $_.Pacote
         Write-Host "Instalando pacote $pacote ..."
         winget install --scope machine --id $pacote
         if ($LastExitCode) {
            Write-Host "O pacote $pacote foi instalado com sucesso."
         }
      }
   }
}


# Exemplo: .\instala-pacotes-winget.ps1 pacotes.txt
