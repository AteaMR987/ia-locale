<#
.SYNOPSIS
    Arrête l'IA locale et libère la mémoire : Morphic et SearXNG, le modèle, Ollama, puis Docker Desktop.

.DESCRIPTION
    Vos données sont conservées (historique de Morphic, mémoire d'Hermes, sessions d'OpenCode).
    Lancement : clic droit sur le fichier > « Exécuter avec PowerShell »,
    ou dans PowerShell : & "C:\Users\ateat\source\outils\arreter-ia-locale.ps1"
#>
$morphic = 'C:\Users\ateat\source\outils\morphic'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host '1/3 Arrêt de Morphic et SearXNG (les données restent)'
docker info --format '{{.ServerVersion}}' 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { Push-Location $morphic; try { docker compose stop } finally { Pop-Location } }

Write-Host '2/3 Arrêt du modèle et d''Ollama'
if (Get-Process ollama -ErrorAction SilentlyContinue) {
    foreach ($m in (ollama ps 2>$null | Select-Object -Skip 1 | ForEach-Object { ($_ -split '\s+')[0] } | Where-Object { $_ })) { ollama stop $m 2>$null }
    Get-Process ollama, 'ollama app' -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host '3/3 Fermeture de Docker Desktop'
docker desktop stop 2>$null
if ($LASTEXITCODE -ne 0) { Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue | Stop-Process -Force }

Write-Host 'Tout est arrêté.' -ForegroundColor Green
