# Analyse de sécurité des 8 outils proposés

Analyse faite le 6 octobre 2026, en lecture seule (API GitHub, fichiers des dépôts, pages gratos.app), avant tout téléchargement.

## La machine

- Windows 11 Pro, Intel Core Ultra 7 155H (16 cœurs), 32 Go de mémoire vive.
- Carte graphique NVIDIA RTX 2000 Ada (8 Go) + Intel Arc intégrée.
- Disque C: 624 Go, 82 Go libres au départ.
- Antivirus : Bitdefender et HP Wolf Pro Security.
- Présents au départ : Git, Ollama 0.24, Chocolatey, winget, uv, Claude Code, WSL 2 (Ubuntu à l'arrêt).
- Absents au départ : Node.js, Bun, Docker, Python, GitHub CLI, Scoop.

## Verdict par outil

| Outil | Sérieux du dépôt | Licence | Windows natif | Ce qui sort du PC | Verdict | Décision |
|---|---|---|---|---|---|---|
| n8n (n8n-io/n8n) | 207 k ★, très actif | Sustainable Use (fair-code) | Docker ou npm | Rien, sauf services branchés | Sûr | Écarté par l'utilisateur |
| OpenBot (CopilotKit/OpenBot) | 6 k ★, créé en août 2026, **alpha** | MIT | Non : Docker obligatoire, `start.sh` en Bash | Conversations chez CopilotKit (cloud ; version locale réservée au Mac), navigateur par bot avec vos identifiants, superviseur qui pilote Docker | **Risqué** | Non installé |
| Hermes Agent (NousResearch/hermes-agent) | 252 k ★ | MIT | Oui : installateur PowerShell officiel | Selon le fournisseur de modèle choisi | Sûr via le site officiel | **Installé, 100 % local** |
| HeliosGen (SegFault42/HeliosGen) | 2,3 k ★, un particulier | **Aucun fichier de licence** | Version web seulement (appli Windows à compiler) | Demandes et images chez Kie.ai (payant), liens d'affiliation | Prudence | Écarté (budget 0 €) |
| OpenDesign (nexu-io/open-design) | 100 k ★ | Apache-2.0 | Oui (418 Mo) | Statistiques PostHog activées par défaut, rapports d'erreurs toujours actifs | Sûr en refusant les statistiques | Écarté par l'utilisateur |
| Morphic (miurla/morphic) | 9 k ★, depuis 2024 | Apache-2.0 | Docker | Questions vers le modèle (aucune avec Ollama) ; SearXNG interroge Google par défaut ; icônes via Google ; adresses de PDF envoyées à Tavily même sans clé | Sûr une fois réglé | **Installé, réglé sans Google** |
| OpenCode (anomalyco/opencode) | 212 k ★ | MIT | Oui (Chocolatey, npm, Scoop) | Le code, vers le fournisseur de modèle ; 2 failles corrigées en janvier 2026 | Sûr si tenu à jour | **Installé, Ollama seulement** |
| Avnac (xt42io/avnac) | 1,6 k ★, plus de commit depuis le 11 mai 2026 | AGPL-3.0 | Oui (Node.js) | Rien (fichiers dans le navigateur) | Sûr mais peu suivi | Écarté par l'utilisateur |

## Pièges relevés

- **hermes-agent.ai n'est pas officiel** : le site se déclare lui-même « fan website, not affiliated with Nous Research ». Seul `hermes-agent.nousresearch.com` est utilisé.
- **Script d'installation d'Hermes audité** (`install.ps1`, 1 424 lignes) : versions épinglées, empreintes SHA-256 sur un miroir Nous Research, aucun droit administrateur, aucune écriture dans le registre, seul ajout : son dossier `bin` au PATH utilisateur.
- **Bitdefender** peut mettre `uv.exe` d'Hermes en quarantaine : faux positif documenté par Nous Research.
- **Consignes de départ en partie périmées** : OpenBot n'a plus besoin de `COPILOTKIT_LICENSE_TOKEN` ; HeliosGen utilise pnpm.
- **Conflits de ports** prévus (3000, 3001, 5432) : résolus en n'ouvrant chaque service que sur 127.0.0.1 et en mettant PostgreSQL de Morphic sur 5433.

## Sources

- Dépôts GitHub listés ci-dessus et leurs fichiers `README.md`, `.env.example`, `docker-compose`, `PRIVACY.md`.
- Pages gratos.app de chaque outil.
- https://hermes-agent.nousresearch.com/install.ps1 (lu avant exécution).
