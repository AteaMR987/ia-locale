# Résultats des tests (7 octobre 2026)

Modèle `qwen3.6-35b-64k` (Ollama 0.40.0, mmap), PC : Core Ultra 7 155H, 32 Go, RTX 2000 Ada 8 Go.

| Outil | Test | Résultat | Durée |
|---|---|---|---|
| Ollama | Question courte en direct | Réponse correcte ; 12,4 jetons/s en écriture (jusqu'à 17 à 20 jetons/s grâce à la prédiction de plusieurs jetons), lecture des consignes ~270 jetons/s | Chargement 16 à 21 s |
| OpenCode | « Lis README.md, angles.py et test_angles.py puis résume le projet » dans `essai-opencode` | ✅ 3 fichiers lus, résumé juste ; **coût affiché 0,00 $** (`opencode stats`) | 148 s |
| OpenCode | Même demande sans nommer les fichiers, hors dépôt Git | ❌ Le modèle a cherché de mauvais dossiers : nommer les fichiers et travailler dans un dépôt Git | 156 s |
| Hermes | Recherche web : rôle du ligament croisé antérieur, 2 sources | ✅ Recherche Brave via SearXNG, réponse en français, 2 vraies sources (Wikipédia, site d'un chirurgien) | 80 s |
| Hermes | Mémoire + sous-agent (3 exercices après entorse de cheville) | ✅ `USER.md` mis à jour ; sous-agent lancé avec le modèle local (session séparée, 69 s), réponse résumée | 127 s |
| Morphic | « Quels sont les muscles principaux de la marche humaine ? » | ✅ Recherche Brave (10 résultats), réponse en français avec sources citées | ≈ 3 min |
| SearXNG | Recherche « biomécanique du genou » | ✅ 20 résultats, moteur `braveapi` seul | < 2 s |

Défauts observés : quelques coquilles du modèle (« faiscripts », « jamme »), et une réflexion interne longue avant chaque réponse. C'est normal pour un modèle local de cette taille.
