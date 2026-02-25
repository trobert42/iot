# Analyse de conformité — Inception-of-Things

Date: 2026-02-25
Référence: Docs/iot.en.subject.txt (v4.0)

## Partie 1 : K3s et Vagrant — CONFORME (1 point mineur)

- [x] 2 machines via Vagrant (chillionS + chillionSW)
- [x] Hostnames = login + S / SW
- [x] IPs : 192.168.56.110 (server), 192.168.56.111 (worker)
- [x] SSH sans mot de passe (insecure_private_key)
- [x] 1 CPU, 1024 MB RAM
- [x] K3s server en mode controller
- [x] K3s agent en mode agent
- [x] kubectl installé et configuré
- [ ] **Dossier `p1/confs/` manquant** — le sujet montre `./p1/confs` dans l'arborescence attendue

## Partie 2 : K3s et 3 applications — CONFORME

- [x] 1 seule VM (chillionS), IP 192.168.56.110
- [x] 3 applications web (app1, app2, app3)
- [x] Routage HOST : app1.com → app1, app2.com → app2, défaut → app3
- [x] app2 avec 3 replicas
- [x] Ingress Traefik configuré
- [x] Dossiers `scripts/` et `confs/` présents

## Partie 3 : K3d et Argo CD — NON CONFORME (2 problèmes critiques)

- [x] K3d installé (pas Vagrant)
- [x] Script d'installation complet (Docker, kubectl, K3d, Argo CD CLI)
- [x] 2 namespaces : argocd + dev
- [x] Argo CD installé dans namespace argocd
- [x] App dans namespace dev
- [x] Repo GitHub avec login dans le nom (chillion/iot-argocd-app)
- [x] Image wil42/playground avec versions v1 et v2
- [x] Port 8888 configuré
- [x] application.yaml avec syncPolicy automated (prune + selfHeal)
- [ ] **`application.yaml` n'est jamais appliquée** — `deploy_app.sh` fait un `kubectl apply` manuel des manifestes au lieu d'appliquer la ressource Argo CD Application
- [ ] **Le déploiement est manuel, pas GitOps** — le script applique deployment.yaml/service.yaml/ingress.yaml directement, ce qui contredit l'exigence du sujet ("automatically deployed by Argo CD using your online GitHub repository")

## Structure globale

- [x] Dossiers p1/, p2/, p3/ à la racine
- [x] Scripts dans scripts/
- [x] Configs dans confs/ (sauf p1)
- [ ] Pas de dossier bonus/ (optionnel, ne bloque pas la partie mandatory)

---

## Reste à faire

### 1. Créer `p1/confs/` (mineur)
Créer le dossier avec un fichier placeholder ou y déplacer une config pertinente pour respecter l'arborescence attendue par le sujet.

### 2. Corriger `p3/scripts/deploy_app.sh` (critique)
Le script doit :
- Appliquer `confs/application.yaml` (la ressource Argo CD Application) au lieu des manifestes manuels
- Laisser Argo CD synchroniser et déployer l'app depuis le repo GitHub
- Supprimer les `kubectl apply` manuels de deployment.yaml, service.yaml, ingress.yaml

Le flux correct est :
```
kubectl apply -f confs/application.yaml
  → Argo CD lit le repo GitHub
    → Argo CD déploie automatiquement dans le namespace dev
```

### 3. S'assurer que le repo GitHub contient les bons manifestes (critique)
Le repo `github.com/chillion/iot-argocd-app` doit contenir :
- deployment.yaml (wil42/playground:v1)
- service.yaml
- ingress.yaml

Ce sont les mêmes fichiers que dans `p3/confs/` (sans application.yaml qui reste local).

### 4. Préparer la démonstration de changement de version (évaluation)
Pendant la soutenance il faut montrer :
1. `curl localhost:8888` → v1
2. Modifier deployment.yaml dans le repo GitHub : v1 → v2
3. Git push
4. Argo CD synchronise automatiquement
5. `curl localhost:8888` → v2
