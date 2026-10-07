# IA locale : agents, recherche et code sans cloud

Projet séparé de WAVE. Il réunit trois outils open source installés sur un PC Windows 11 (32 Go de mémoire vive, NVIDIA RTX 2000 Ada 8 Go). Ils fonctionnent **sans payer**, et **sans envoyer de données à un fournisseur d'IA** :

| Outil | Rôle | Accès |
|---|---|---|
| [Hermes Agent](https://github.com/NousResearch/hermes-agent) v0.21.5 | Agent qui raisonne, se souvient, apprend des compétences et délègue à des sous-agents | `hermes` dans PowerShell |
| [Morphic](https://github.com/miurla/morphic) | Moteur de réponses avec recherche web (remplace Perplexity) | http://localhost:3000 |
| [OpenCode](https://github.com/anomalyco/opencode) 1.18 | Agent de code dans le terminal | `opencode` dans un dossier de code |

Les trois utilisent le même modèle local : **Qwen 3.6 35B** (MoE, 3 milliards de paramètres actifs, 64K de contexte, vision). Il tourne avec **Ollama 0.40**. La recherche web passe par un **SearXNG** local, qui interroge uniquement l'**API Brave** (jamais Google).

```
 Hermes ─┐                     ┌─> Ollama (qwen3.6-35b-64k) ── sur le PC
 OpenCode┼── 127.0.0.1 ────────┤
 Morphic ┘  (rien sur le Wi-Fi) └─> SearXNG (Docker) ──> API Brave (seule sortie : le texte des recherches)
```

## Démarrage rapide

```powershell
& "C:\Users\ateat\source\repos\ia-locale\scripts\demarrer-ia-locale.ps1"
```

Pour tout arrêter et libérer la mémoire :

```powershell
& "C:\Users\ateat\source\repos\ia-locale\scripts\arreter-ia-locale.ps1"
```

## Contenu du dépôt

| Chemin | Contenu |
|---|---|
| `docs/guide-complet.html` | **Guide complet** (18 chapitres) : ouvrir dans un navigateur |
| `docs/guide-utilisation.md` | Version courte : utilisation, mises à jour, ce qui sort du PC, dépannage |
| `docs/analyse-securite.md` | Analyse des 8 outils proposés au départ et verdicts |
| `docs/choix-du-modele.md` | Comparaison des modèles locaux et mesures |
| `docs/journal-des-decisions.md` | Toutes les décisions (IA-001 à IA-027) |
| `docs/resultats-des-tests.md` | Tests de bout en bout des trois outils |
| `config/hermes/appliquer-reglages-hermes.ps1` | Réglages « 100 % local » d'Hermes et liste blanche d'outils |
| `config/ollama/qwen3.6-35b-64k.Modelfile` | Modèle 64K avec mmap |
| `config/opencode/opencode.json` | OpenCode limité à Ollama |
| `config/morphic/` | Réglages Docker et SearXNG de Morphic (modèle de fichier **sans** la clé Brave) |
| `config/wsl/wslconfig.example` | Limite de 6 Go pour WSL et Docker |
| `scripts/` | Démarrage, arrêt, téléchargement de modèles avec reprise |
| `essai-opencode/` | Petit projet de biomécanique servant de test à OpenCode |

## Emplacements sur le PC

| Élément | Dossier |
|---|---|
| Hermes (code, réglages, mémoire) | `%LOCALAPPDATA%\hermes` |
| Morphic (code et réglages locaux, dont la clé Brave) | `C:\Users\ateat\source\outils\morphic` |
| Modèles Ollama | `%USERPROFILE%\.ollama\models` |
| Journaux d'installation et de test | `C:\Users\ateat\source\outils\journaux` |

Aucun secret n'est versionné : la clé Brave et le secret de SearXNG restent dans des fichiers ignorés par Git.
