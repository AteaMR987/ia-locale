<#
.SYNOPSIS
    Télécharge un modèle Ollama, même sur une connexion Wi-Fi qui coupe souvent.

.DESCRIPTION
    « ollama pull » repart de zéro quand la connexion coupe avant la fin d'un morceau.
    Ce script télécharge lui-même les fichiers depuis le registre officiel (registry.ollama.ai) :
    - une seule connexion, en IPv4, qui reprend à l'octet près après chaque coupure ;
    - attente patiente quand le réseau disparaît (nouvel essai espacé jusqu'à 5 minutes) ;
    - contrôle SHA-256 de chaque fichier avant de le ranger ;
    - aucun fichier supprimé : un fichier douteux est mis de côté sous un autre nom.
    Relancer le script reprend là où il s'est arrêté ; un modèle déjà installé est sauté.
    Après le téléchargement, redémarrez Ollama pour qu'il voie le nouveau modèle.

.PARAMETER Modeles
    Liste ordonnée de modèles Ollama, par exemple « qwen3.6:35b ».

.PARAMETER Journal
    Fichier où chaque étape est notée, en plus de l'écran.

.PARAMETER HeuresMax
    Au-delà de cette durée, le script s'arrête proprement ; une relance reprend là où il en était.

.EXAMPLE
    .\scripts\telecharger-modele-ollama.ps1 -Modeles "qwen3.6:35b"
#>
param(
    [string[]]$Modeles = @("qwen3.6:35b"),
    [string]$Journal = "C:\Users\ateat\source\outils\journaux\telechargements-modeles.log",
    [double]$HeuresMax = 12
)

$ErrorActionPreference = 'Continue'
$modelesOllama = if ($env:OLLAMA_MODELS) { $env:OLLAMA_MODELS } else { Join-Path $env:USERPROFILE ".ollama\models" }
# Sur le même disque que les modèles (le rangement final est un simple renommage), mais hors du
# dossier « blobs », qu'Ollama nettoie à son démarrage.
$attenteOllama = Join-Path (Split-Path $modelesOllama) "telechargements"
New-Item -ItemType Directory -Force $attenteOllama, (Join-Path $modelesOllama "blobs"), (Split-Path $Journal) | Out-Null
$script:Limite = (Get-Date).AddHours($HeuresMax)

function Ecrire([string]$message) {
    $ligne = "{0:HH:mm:ss} {1}" -f (Get-Date), $message
    Write-Host $ligne
    Add-Content -LiteralPath $Journal -Value $ligne -Encoding UTF8
}

# Taille réelle, même pendant l'écriture (l'Explorateur affiche parfois 0 tant que le fichier est ouvert).
function Taille([string]$chemin) {
    if (-not (Test-Path -LiteralPath $chemin)) { return 0 }
    $flux = [System.IO.File]::Open($chemin, 'Open', 'Read', 'ReadWrite')
    try { return $flux.Length } finally { $flux.Close() }
}

function Empreinte([string]$chemin) { (Get-FileHash -LiteralPath $chemin -Algorithm SHA256).Hash.ToLowerInvariant() }

# Petite réponse texte (manifeste), redemandée patiemment tant que le réseau manque.
function LireTexte([string[]]$arguments) {
    $pause = 5
    while ((Get-Date) -lt $script:Limite) {
        $sortie = & curl.exe -4 -s -S --connect-timeout 30 --max-time 60 @arguments 2>$null
        if ($LASTEXITCODE -eq 0 -and $sortie) { return ($sortie -join "`n") }
        Start-Sleep -Seconds $pause
        $pause = [Math]::Min(300, $pause * 2)
    }
    return $null
}

# Télécharge $url dans $cible en reprenant là où le fichier s'est arrêté, jusqu'à $attendue octets.
function Recuperer([string]$url, [string]$cible, [int64]$attendue) {
    $nom = Split-Path $cible -Leaf
    if ((Taille $cible) -gt $attendue) {
        Ecrire "$nom : plus gros que prévu, mis de côté (.corrompu)"
        Move-Item -LiteralPath $cible -Destination "$cible.corrompu" -Force
    }
    $pause = 3
    $dernierAvis = [datetime]::MinValue
    while ((Taille $cible) -lt $attendue) {
        if ((Get-Date) -gt $script:Limite) { return $false }
        $avant = Taille $cible
        $debut = Get-Date
        & curl.exe -4 -L -s -S --connect-timeout 30 --speed-limit 20000 --speed-time 60 -C - -o $cible $url 2>$null
        $code = $LASTEXITCODE
        $apres = Taille $cible
        if ($apres -gt $avant) {
            $pause = 3
            $debit = ($apres - $avant) / 1MB / [Math]::Max(1, ((Get-Date) - $debut).TotalSeconds)
            $suite = if ($apres -lt $attendue) { " ; coupure (code $code), reprise" } else { "" }
            Ecrire ("{0} : {1:N0} / {2:N0} Mo, {3:N1} Mo/s{4}" -f $nom, ($apres / 1MB), ($attendue / 1MB), $debit, $suite)
        }
        else {
            # Pas de réseau, ou serveur muet : on patiente de plus en plus longtemps, jusqu'à 5 minutes.
            $pause = [Math]::Min(300, $pause * 2)
            if (((Get-Date) - $dernierAvis).TotalMinutes -ge 10) {
                Ecrire ("{0} : réseau indisponible (code curl {1}) ; nouvel essai toutes les {2} s au plus, jusqu'à {3:HH:mm}" -f $nom, $code, $pause, $script:Limite)
                $dernierAvis = Get-Date
            }
        }
        if ((Taille $cible) -lt $attendue) { Start-Sleep -Seconds $pause }
    }
    return $true
}

function Ollama([string]$nom) {
    $depot, $etiquette = $nom -split ':', 2
    if (-not $etiquette) { $etiquette = "latest" }
    $chemin = if ($depot.Contains('/')) { $depot } else { "library/$depot" }
    $fichierManifeste = Join-Path $modelesOllama ("manifests\registry.ollama.ai\" + $chemin.Replace('/', '\') + "\" + $etiquette)
    if (Test-Path -LiteralPath $fichierManifeste) { Ecrire "$nom : déjà présent"; return "PRÉSENT" }
    $brut = LireTexte @('-H', 'Accept: application/vnd.docker.distribution.manifest.v2+json', "https://registry.ollama.ai/v2/$chemin/manifests/$etiquette")
    try { $manifeste = $brut | ConvertFrom-Json } catch { $manifeste = $null }
    if (-not $manifeste -or -not $manifeste.layers) { Ecrire "$nom : modèle introuvable dans le registre d'Ollama, ou réseau absent"; return "REPORTÉ" }
    $couches = @($manifeste.config) + @($manifeste.layers)
    $total = ($couches | Measure-Object -Property size -Sum).Sum
    Ecrire ("{0} : {1} fichiers, {2:N2} Go depuis registry.ollama.ai" -f $nom, $couches.Count, ($total / 1GB))
    $aRanger = @()
    foreach ($couche in $couches) {
        $hex = $couche.digest.Substring(7)
        $final = Join-Path $modelesOllama "blobs\sha256-$hex"
        if ((Taille $final) -eq [int64]$couche.size) { continue }
        $part = Join-Path $attenteOllama "sha256-$hex.part"
        if (-not (Recuperer "https://registry.ollama.ai/v2/$chemin/blobs/$($couche.digest)" $part ([int64]$couche.size))) {
            Ecrire "$nom : INCOMPLET, relancer le script pour reprendre"
            return "INCOMPLET"
        }
        if ((Empreinte $part) -ne $hex) {
            Ecrire "$nom : empreinte fausse pour sha256-$hex, fichier mis de côté (.corrompu)"
            Move-Item -LiteralPath $part -Destination "$part.corrompu" -Force
            return "ÉCHEC"
        }
        $aRanger += [pscustomobject]@{ Part = $part; Final = $final }
    }
    # Tout est vérifié : les fichiers sont rangés, puis le manifeste écrit, ce qui rend le modèle visible d'un coup.
    foreach ($f in $aRanger) { Move-Item -LiteralPath $f.Part -Destination $f.Final -Force }
    New-Item -ItemType Directory -Force (Split-Path $fichierManifeste) | Out-Null
    [System.IO.File]::WriteAllText($fichierManifeste, $brut, [System.Text.UTF8Encoding]::new($false))
    Ecrire ("{0} : PRÊT ({1:N2} Go, SHA-256 vérifié)" -f $nom, ($total / 1GB))
    return "PRÊT"
}

# Une seule copie du script à la fois.
$verrou = [System.Threading.Mutex]::new($false, "Local\IALocale.TelechargementModeles")
if (-not $verrou.WaitOne(0)) { Ecrire "Un téléchargement de modèles est déjà en cours : rien à faire."; exit 0 }
try {
    Ecrire ("=== Téléchargement de {0} modèle(s), jusqu'à {1:HH:mm} au plus" -f $Modeles.Count, $script:Limite)
    $bilan = foreach ($m in $Modeles) { "{0} : {1}" -f $m, (Ollama $m) }
    Ecrire ("=== Bilan : " + ($bilan -join " | "))
    Ecrire "TERMINÉ"
}
finally {
    $verrou.ReleaseMutex()
}
