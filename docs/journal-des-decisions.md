# Journal des décisions

Projet séparé de WAVE, à la demande de l'utilisateur (7 octobre 2026). Chaque décision : date, choix, raison.

| N° | Date | Décision | Raison |
|---|---|---|---|
| IA-001 | 06/10 | Analyser les 8 dépôts en lecture seule avant tout téléchargement | Vérifier sécurité, licences et compatibilité Windows (voir `analyse-securite.md`) |
| IA-002 | 06/10 | Ne pas installer OpenBot | Alpha, Docker et Bash obligatoires, conversations stockées dans le cloud de CopilotKit, accès aux identifiants des sites |
| IA-003 | 06/10 | Garder seulement Hermes Agent, Morphic et OpenCode | Choix de l'utilisateur : agents intelligents, de recherche et de code, sans payer ; n8n, HeliosGen, OpenDesign et Avnac écartés |
| IA-004 | 06/10 | Accepter Docker Desktop pour ces outils | Indispensable à Morphic et SearXNG ; la règle « jamais Docker » concernait WAVE |
| IA-005 | 06/10 | Budget 0 € : tout en local avec Ollama | Aucune clé d'API payante, aucune donnée chez un fournisseur d'IA |
| IA-006 | 06/10 | Modèle qwen3.6:35b (MoE 35B, 3 Md actifs), et non Gemma 4 | Meilleur en agent et en code parmi les modèles assez rapides pour 8 Go de carte graphique (voir `choix-du-modele.md`) |
| IA-007 | 06/10 | Téléchargement des modèles par script avec reprise (`scripts/telecharger-modele-ollama.ps1`) | Le Wi-Fi coupe souvent : `ollama pull` repart de zéro |
| IA-008 | 06/10 | Limiter WSL et Docker à 6 Go (`.wslconfig`) | Laisser la mémoire au modèle |
| IA-009 | 06/10 | Hermes installé avec le script officiel, sans le contrôle du bureau (`-SkipComputerUse`) | Capacité risquée non demandée |
| IA-010 | 06/10 | Hermes : modèle local, `adopt_external_logins: false`, télémétrie coupée | Empêcher l'emprunt de la connexion Claude Code (messages envoyés à Anthropic) |
| IA-011 | 06/10 | Liste blanche d'outils Hermes : search, browser, file, memory, session_search, skills, delegation, cronjob, todo, clarify (10 groupes, 32 outils sur 91) | Demande de l'utilisateur ; terminal, exécution de code, contrôle du bureau, images, voix et connexions coupés ; les 4 derniers groupes servent la mémoire qui évolue et le raisonnement |
| IA-012 | 06/10 | Aucune messagerie branchée à Hermes | L'utilisateur n'utilise ni Discord, ni Telegram, ni WhatsApp ; elles passent par des serveurs tiers |
| IA-013 | 06/10 | Recherche web : SearXNG local, Brave uniquement, jamais Google | Règle de l'utilisateur |
| IA-014 | 06/10 | Moteur `braveapi` (API officielle, offre gratuite de 5 $/mois) au lieu de `brave` | Brave bloque les requêtes de SearXNG sans clé (« too many requests ») |
| IA-015 | 06/10 | Hermes : `web.keyless_fallback: false` | Sans ce réglage, Hermes enverrait les adresses lues au service gratuit « Parallel » |
| IA-016 | 06/10 | Hermes lit les pages avec son navigateur Chromium local | Tous les autres lecteurs de pages d'Hermes sont des services en ligne |
| IA-017 | 06/10 | Morphic : image officielle `ghcr.io/miurla/morphic`, ports sur 127.0.0.1, PostgreSQL sur 5433, aucun redémarrage automatique | Pas de compilation, rien d'ouvert sur le réseau Wi-Fi, rien au démarrage de Windows |
| IA-018 | 06/10 | Morphic : `FAVICON_PROVIDER_URL=off` et `api.tavily.com` rendu injoignable | Les icônes passaient par Google ; les adresses de PDF partaient chez Tavily même sans clé |
| IA-019 | 06/10 | OpenCode par Chocolatey, `enabled_providers: ["ollama"]`, partage désactivé, mises à jour signalées seulement | Aucun fournisseur en ligne possible, aucune session partagée |
| IA-020 | 07/10 | Mise à jour d'Ollama 0.24.0 → 0.40.0 | qwen3.6 exige Ollama 0.30.0 ou plus |
| IA-021 | 07/10 | `use_mmap true` dans le modèle 64K | Chargement 16 s au lieu de 75 s, 12,4 au lieu de 9,3 jetons/s, 8 Go réservés au lieu de 26 |
| IA-022 | 07/10 | Lancer Ollama par l'Explorateur dans `demarrer-ia-locale.ps1` | Lancé depuis certains programmes, Ollama hérite d'une protection Windows (erreur 448) et ne lit plus ses modèles |
| IA-023 | 07/10 | Démarrage automatique d'Ollama avec Windows laissé tel quel | Il existait avant ce projet ; Ollama au repos consomme peu |
| IA-024 | 07/10 | Dépôt séparé `ia-locale`, privé | Ne pas mélanger avec WAVE ; aucune clé ni donnée personnelle dans Git |
