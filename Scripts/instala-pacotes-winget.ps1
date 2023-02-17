if ($args.Length -eq 2) {
   if (Test-Path -Path $args[1] -PathType Leaf) {
      Import-Csv -Path $args[1] -Header Pacote | ForEach-Object {
         winget install --id $_.Pacote
      }
   }
}

# Exemplo: .\instala-pacotes-winget.ps1 pacotes.txt
