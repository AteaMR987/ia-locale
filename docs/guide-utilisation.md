# Guide d'utilisation

## 1. Démarrer et arrêter

Rien ne démarre avec Windows, sauf Ollama, qui le faisait déjà avant ce projet. Lancez les outils seulement quand vous en avez besoin.

```powershell
& "C:\Users\ateat\source\repos\ia-locale\scripts\demarrer-ia-locale.ps1"
```

Ce script démarre Ollama, Docker Desktop, puis Morphic et SearXNG, et vérifie que chacun répond (comptez 1 à 3 minutes).

```powershell
& "C:\Users\ateat\source\repos\ia-locale\scripts\arreter-ia-locale.ps1"
```

Ce script arrête tout et libère la mémoire ; vos données sont conservées.

Vous pouvez aussi faire un clic droit sur un script, puis choisir « Exécuter avec PowerShell ».

## 2. Hermes Agent : l'agent qui apprend

| Action | Commande PowerShell |
|---|---|
| Discuter (mode interactif) | `hermes` |
| Poser une seule question | `hermes chat -q "Ta question"` |
| Voir les outils actifs | `hermes tools --summary` |
| Diagnostic complet | `hermes doctor` |
| Mettre à jour | `hermes update` (les réglages sont conservés) |
| Réappliquer les réglages locaux | `& "C:\Users\ateat\source\repos\ia-locale\config\hermes\appliquer-reglages-hermes.ps1"` |

- **Mémoire :** Hermes garde des notes sur vous et sur ses tâches (`%LOCALAPPDATA%\hermes\memories`). Il retrouve aussi ses anciennes conversations (Session Search), et écrit lui-même de nouvelles compétences à force d'expérience (Skills). Un « conservateur » range ces compétences automatiquement ; sa première passe a lieu environ 7 jours après l'installation, et il ne supprime jamais rien.
- **Sous-agents :** demandez par exemple « Utilise deux sous-agents pour comparer X et Y ». Au plus 2 travaillent en même temps, car ils partagent le même modèle local.
- **Recherche web :** passe par SearXNG, donc Morphic doit être démarré (script de démarrage). Hermes lit ensuite les pages avec son navigateur local.
- **Tâches planifiées :** elles ne s'exécutent que si la passerelle d'Hermes tourne (`hermes gateway`) ; elle ne démarre jamais seule.
- **Lenteur normale :** la première réponse peut prendre 1 à 3 minutes, car Hermes envoie de longues consignes au modèle local.
- **Réglages :** `%LOCALAPPDATA%\hermes\config.yaml` (sauvegarde d'origine : `config.yaml.avant-reglages-locaux`).

## 3. Morphic : le moteur de recherche avec IA

- Ouvrir **http://localhost:3000**. L'adresse n'est accessible que depuis ce PC.
- Dans le sélecteur de modèle, choisir **qwen3.6-35b-64k**. Les autres modèles listés fonctionnent aussi : `qwen3.5:9b` est plus rapide mais moins intelligent.
- L'historique est enregistré dans la base PostgreSQL locale, sans compte.
- Les recherches passent par l'API Brave (5 $ offerts par mois, soit environ 1 000 requêtes ; une question en lance souvent 2 à 5).
- **Mettre à jour :**
  ```powershell
  Set-Location C:\Users\ateat\source\outils\morphic; git pull; docker compose pull; docker compose up -d
  ```
- **Changer la clé Brave :** créer une nouvelle clé sur https://api-dashboard.search.brave.com et supprimer l'ancienne. Remplacer la clé dans `C:\Users\ateat\source\outils\morphic\searxng-settings.local.yml`, puis lancer `docker compose restart searxng` dans ce dossier.

## 4. OpenCode : l'agent de code

- Ouvrir PowerShell dans un dossier de code (de préférence un dépôt Git), puis taper `opencode`.
- Le modèle `ollama/qwen3.6-35b-64k` est choisi par défaut. Le coût de la session s'affiche dans l'interface ; `opencode stats` donne le total. Il reste à 0,00 $, puisque tout tourne en local.
- Demandes efficaces avec ce modèle : nommez les fichiers à lire, par exemple « Lis README.md et angles.py puis… ».
- **Mettre à jour**, dans un PowerShell ouvert en administrateur : `choco upgrade opencode -y`
- **Réglages :** `C:\Users\ateat\.config\opencode\opencode.json` (copie dans `config\opencode`).

## 5. Ollama et le modèle

- `ollama list` : modèles installés ; `ollama ps` : modèle chargé et répartition processeur/carte graphique.
- **Recréer le modèle 64K** (aucun téléchargement) :
  ```powershell
  ollama create qwen3.6-35b-64k -f C:\Users\ateat\source\repos\ia-locale\config\ollama\qwen3.6-35b-64k.Modelfile
  ```
- **Télécharger un autre modèle sur un Wi-Fi qui coupe :**
  ```powershell
  & C:\Users\ateat\source\repos\ia-locale\scripts\telecharger-modele-ollama.ps1 -Modeles "nom:taille"
  ```
  Redémarrez ensuite Ollama.
- **Mettre à jour Ollama :** télécharger `OllamaSetup.exe` depuis https://github.com/ollama/ollama/releases et vérifier la signature « Ollama Inc. ». Si l'installation est lancée en ligne de commande, ajouter `/VERYSILENT`.

## 6. Ce qui sort du PC

| Vers | Quoi | Quand |
|---|---|---|
| API Brave | Le texte de la recherche | Chaque recherche web (Hermes, Morphic) |
| Sites web consultés | L'adresse IP du PC | Quand Hermes ou Morphic lisent une page |
| GitHub, Docker Hub, npm, Chocolatey | Rien de personnel | Mises à jour |
| Fournisseurs d'IA (OpenAI, Anthropic, Google…) | **Rien** | Jamais : le modèle tourne sur le PC |

Coupés exprès :
- statistiques d'Hermes ;
- emprunt de la connexion Claude Code ;
- lecteur de pages en ligne « Parallel » ;
- Tavily ;
- icônes Google ;
- partage des sessions OpenCode.

## 7. GitHub pour Hermes (étape restante, facultative)

La compétence GitHub d'Hermes utilise la commande `gh` dans le Terminal, que la liste blanche coupe volontairement. La voie sûre :

1. Sur GitHub : Settings → Developer settings → Fine-grained tokens → Generate new token. Choisissez **Only select repositories : wave**, avec les droits Issues et Pull requests en lecture et écriture, et Contents en lecture.
2. Ajoutez le serveur MCP officiel de GitHub à Hermes avec ce jeton. C'est vous qui collez le jeton dans `%LOCALAPPDATA%\hermes\.env`, jamais dans une conversation.
3. Ajoutez seulement les outils GitHub voulus à la liste blanche (notation `github:nom_outil`).

Le jeton ne donne alors accès qu'au dépôt `wave`, et Hermes ne peut toujours exécuter aucune commande sur le PC.

## 8. Dépannage

| Problème | Solution |
|---|---|
| Erreur « point de montage non approuvé » (448) avec Ollama | Fermer Ollama, puis le relancer depuis le menu Démarrer (ou avec le script de démarrage) |
| Morphic ou Hermes ne trouvent rien sur le web | Lancer le script de démarrage ; vérifier le crédit Brave sur api-dashboard.search.brave.com |
| PC lent pendant l'IA | Normal pendant une réponse ; le script d'arrêt libère la mémoire |
| Bitdefender bloque `uv.exe` d'Hermes | Faux positif connu : restaurer le fichier depuis la quarantaine et ajouter une exception pour `%LOCALAPPDATA%\hermes\bin` |
| Docker ne démarre pas | Ouvrir Docker Desktop à la main et lire le message ; fermer puis rouvrir la session Windows |
