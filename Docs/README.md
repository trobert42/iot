# Documentation Directory

Ce répertoire contient la documentation détaillée du projet IoT.

## Documents disponibles

### `CONSIGNES_POINTS_CLES.md`
📋 **Document principal pour l'évaluation**

Contient tous les points critiques et exigences détaillées pour chaque partie :
- Structure obligatoire des fichiers
- Configurations exactes requises
- Points de vérification pour l'évaluateur
- Checklist de conformité

**Utilisation :** À consulter avant l'évaluation et en cas de doute sur les exigences.

### `GITIGNORE_INFO.md`
📝 **Explication du fichier .gitignore**

Documentation détaillée des fichiers et répertoires ignorés :
- Fichiers temporaires Vagrant
- Données Docker/K3d
- Configurations Kubernetes sensibles
- Logs et caches
- Justification de chaque exclusion

**Utilisation :** Pour comprendre pourquoi certains fichiers ne sont pas versionnés.

## Accès rapide

- Via Makefile : `make help` affiche les liens vers cette documentation
- Depuis le README principal : liens directs vers chaque document
- Structure visible avec : `tree Docs/` ou `ls -la Docs/`
