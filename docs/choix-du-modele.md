# Choix du modèle d'IA local

## Contraintes

- Aucun euro dépensé, aucune donnée envoyée à un fournisseur d'IA : modèle exécuté par Ollama sur le PC.
- 8 Go de mémoire graphique et 32 Go de mémoire vive : seul un modèle **MoE** (seule une petite partie s'active à chaque mot) reste assez rapide. Un modèle « dense » de 27 à 30 milliards de paramètres ferait environ 3 à 5 mots par seconde.
- Hermes Agent exige au moins **64 000 jetons de contexte**.
- Outils, vision et réflexion (« thinking ») souhaités pour un agent.

## Comparaison (Ollama, octobre 2026)

| Modèle | Type | Taille | Points forts publiés | Décision |
|---|---|---|---|---|
| **qwen3.6:35b** | MoE, 3 Md actifs | 21,1 Go | SWE-bench Verified 73,4 %, vision, réflexion conservée entre messages | **Choisi** |
| qwen3.5:35b | MoE, 3 Md actifs | 20,6 Go | Version précédente | Remplacé |
| gemma4:26b | MoE, 4 Md actifs | 17,4 Go | Tau2 68,2 % ; Gemma 4 31B fait 54,2 sur MCP Atlas contre 62,5 pour Qwen 3.6 27B | Plus faible en agent |
| nemotron-3.5-lightning | MoE, 3 Md actifs | 25 Go | Très rapide, 1 M de contexte ; SWE-bench Verified 51,6 % | Moins intelligent |
| laguna-xs-2.1 | MoE, 3 Md actifs | 20 Go | SWE-bench Verified 70,9 %, texte seul | Derrière Qwen 3.6 |
| muse-glimmer, qwen3.8:27b | Denses | 18 Go | Meilleurs scores d'agent (MCP Atlas 75,5) | Trop lents sur ce PC |
| glm-5.3-flash | 320 Md | Cloud seulement | Proche de Claude | Exclu : données en ligne |

Sources : pages des modèles sur ollama.com/library, NYU Shanghai (Muse Glimmer dense), DataCamp (Nemotron 3.5 Lightning).

## Réglages retenus (`config/ollama/qwen3.6-35b-64k.Modelfile`)

- `num_ctx 65536` : 64K de contexte (Ollama n'en donne que 4 096 par défaut).
- `use_mmap true` : le modèle est lu depuis son fichier au lieu d'être copié en mémoire réservée.

## Mesures (7 octobre 2026, Ollama 0.40.0)

| | Sans mmap | Avec mmap |
|---|---|---|
| Chargement | 75 s | 16 à 21 s |
| Vitesse d'écriture | 9,3 jetons/s | 12,4 jetons/s |
| Mémoire réservée par le modèle | 26 Go | 8,3 Go |
| Mémoire encore disponible | 1,1 Go | 7,5 à 12 Go |
| Répartition | 83 % processeur / 17 % carte graphique | idem |

Le modèle exige **Ollama 0.30.0 ou plus** : Ollama a été mis à jour de 0.24.0 à 0.40.0.

## Limite à connaître

Aucun modèle qui tient sur ce PC n'atteint Claude, ChatGPT ou Gemini. Attendre un agent correct pour des tâches simples à moyennes, plus lent (la première réponse d'un agent avec de longues consignes peut prendre plusieurs minutes) et moins fiable sur les longues tâches. Les sous-agents se partagent le même modèle : ils avancent surtout les uns après les autres.
