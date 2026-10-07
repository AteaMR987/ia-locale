<#
.SYNOPSIS
    Applique à Hermes Agent les réglages « 100 % local, aucune fuite » de ce projet.

.DESCRIPTION
    À relancer après une réinstallation d'Hermes (les mises à jour, elles, conservent ces réglages).
    Utilise uniquement les commandes officielles « hermes config set ».
    Ce que fait chaque réglage :
    - model.*                    : cerveau = Ollama sur ce PC, modèle qwen3.6-35b-64k (contexte 64K exigé par Hermes) ;
    - auth.adopt_external_logins : n'emprunte jamais la connexion de Claude Code ou de Codex (sinon vos messages
                                   partiraient chez Anthropic ou OpenAI) ;
    - telemetry.*                : statistiques Nous Research coupées (déjà coupées par défaut, vérifié) ;
    - web.backend + SEARXNG_URL  : recherche web par le SearXNG local (Docker de Morphic), qui interroge l'API Brave ;
    - web.keyless_fallback       : interdit les services gratuits sans clé (ex. « Parallel ») qui recevraient les
                                   adresses lues, même via une référence @https://... dans un message ;
    - delegation.*               : au plus 2 sous-agents en parallèle (le modèle local est partagé) ;
    - platform_toolsets.cli      : liste blanche des outils (tout le reste est coupé).
    Les tâches annexes (résumés, titres, apprentissage) restent sur « auto », c'est-à-dire le modèle principal, donc local.
#>
$ErrorActionPreference = 'Stop'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

$reglages = [ordered]@{
    'model.provider'                    = 'custom'
    'model.base_url'                    = 'http://127.0.0.1:11434/v1'
    'model.default'                     = 'qwen3.6-35b-64k'
    'model.context_length'              = '65536'
    'auth.adopt_external_logins'        = 'false'
    'telemetry.shared_metrics.enabled'  = 'false'
    'telemetry.shared_metrics.send'     = 'false'
    'web.backend'                       = 'searxng'
    'web.keyless_fallback'              = 'false'
    'delegation.max_concurrent_children' = '2'
    'platform_toolsets.cli'             = '[search, browser, file, memory, session_search, skills, delegation, cronjob, todo, clarify]'
}
foreach ($cle in $reglages.Keys) {
    & hermes config set $cle $reglages[$cle] | Select-Object -First 1
}

# Adresse du SearXNG local, lue par Hermes dans son fichier .env.
$envHermes = (& hermes config env-path).Trim()
if (-not (Select-String -LiteralPath $envHermes -Pattern '^SEARXNG_URL=' -Quiet)) {
    Add-Content -LiteralPath $envHermes -Value "`n# Recherche web : SearXNG local (Docker de Morphic), API Brave`nSEARXNG_URL=http://127.0.0.1:8080" -Encoding utf8
}

Write-Host ''
Write-Host 'Vérification :' -ForegroundColor Cyan
& hermes tools --summary
