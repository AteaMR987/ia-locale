<#
.SYNOPSIS
    Démarre l'IA locale : Ollama (le modèle), Docker Desktop, puis Morphic et SearXNG.

.DESCRIPTION
    Rien ne démarre avec Windows : lancez ce script quand vous voulez utiliser Hermes, OpenCode ou Morphic.
    Tout reste sur ce PC (ports ouverts sur 127.0.0.1 seulement).
    Lancement : clic droit sur le fichier > « Exécuter avec PowerShell »,
    ou dans PowerShell : & "C:\Users\ateat\source\outils\demarrer-ia-locale.ps1"
#>
$ErrorActionPreference = 'Stop'
# Ollama est lancé par l'Explorateur (comme un clic dans le menu Démarrer) : lancé depuis certains
# programmes, il hérite d'une protection Windows qui l'empêche de lire ses propres modèles (erreur 448).
$ollamaApp = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama app.exe'
$dockerDesktop = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
$morphic = 'C:\Users\ateat\source\outils\morphic'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

function Attendre([string]$quoi, [scriptblock]$test, [int]$secondes) {
    $fin = (Get-Date).AddSeconds($secondes)
    while ((Get-Date) -lt $fin) {
        try { if (& $test) { Write-Host "  OK : $quoi" -ForegroundColor Green; return $true } } catch { }
        Start-Sleep -Seconds 3
    }
    Write-Host "  ÉCHEC : $quoi ne répond pas après $secondes s" -ForegroundColor Red
    return $false
}

Write-Host '1/3 Ollama (modèle local)'
if (-not (Get-Process ollama -ErrorAction SilentlyContinue)) { Start-Process -FilePath 'explorer.exe' -ArgumentList "`"$ollamaApp`"" }
$null = Attendre 'Ollama' { (Invoke-RestMethod 'http://127.0.0.1:11434/api/version' -TimeoutSec 3).version } 60

Write-Host '2/3 Docker Desktop'
if (-not (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue)) { Start-Process -FilePath $dockerDesktop }
if (-not (Attendre 'Docker' { docker info --format '{{.ServerVersion}}' 2>$null; $LASTEXITCODE -eq 0 } 240)) { exit 1 }

Write-Host '3/3 Morphic et SearXNG (recherche Brave)'
Push-Location $morphic
try { docker compose up -d } finally { Pop-Location }
$null = Attendre 'SearXNG' { (Invoke-WebRequest 'http://127.0.0.1:8080/healthz' -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200 } 90
$null = Attendre 'Morphic' { (Invoke-WebRequest 'http://127.0.0.1:3000' -UseBasicParsing -TimeoutSec 10).StatusCode -eq 200 } 120

Write-Host ''
Write-Host 'Prêt :' -ForegroundColor Cyan
Write-Host '  - Morphic (recherche)  : http://localhost:3000  (modèle « qwen3.6-35b-64k » dans le sélecteur)'
Write-Host '  - Hermes (agent)       : tapez  hermes  dans PowerShell'
Write-Host '  - OpenCode (code)      : allez dans un dossier de code puis tapez  opencode'
Write-Host '  - Pour tout arrêter    : arreter-ia-locale.ps1'
