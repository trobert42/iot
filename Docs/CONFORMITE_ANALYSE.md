# Analyse de conformité — Inception-of-Things

Date: 2026-02-25
Référence: Docs/iot.en.subject.txt (v4.0)

## Partie 1 : K3s et Vagrant — CONFORME

- [x] 2 machines via Vagrant (chillionS + chillionSW)
- [x] Hostnames = login + S / SW
- [x] IPs : 192.168.56.110 (server), 192.168.56.111 (worker)
- [x] SSH sans mot de passe (insecure_private_key)
- [x] 1 CPU, 1024 MB RAM
- [x] K3s server en mode controller
- [x] K3s agent en mode agent
- [x] kubectl installé et configuré
- [x] Dossier `p1/confs/` présent

## Partie 2 : K3s et 3 applications — CONFORME

- [x] 1 seule VM (chillionS), IP 192.168.56.110
- [x] 3 applications web (app1, app2, app3)
- [x] Routage HOST : app1.com → app1, app2.com → app2, défaut → app3
- [x] app2 avec 3 replicas
- [x] Ingress Traefik configuré
- [x] Dossiers `scripts/` et `confs/` présents

## Partie 3 : K3d et Argo CD — CONFORME

- [x] K3d installé (pas Vagrant)
- [x] Script d'installation complet (Docker, kubectl, K3d, Argo CD CLI)
- [x] 2 namespaces : argocd + dev
- [x] Argo CD installé dans namespace argocd
- [x] App dans namespace dev
- [x] Repo GitHub avec login dans le nom (BekxFR/trobert-iot-argocd-app)
- [x] Image wil42/playground avec versions v1 et v2
- [x] Port 8888 configuré
- [x] application.yaml avec syncPolicy automated (prune + selfHeal)
- [x] `deploy_app.sh` applique `application.yaml` (Argo CD Application) — déploiement GitOps
- [x] Argo CD synchronise automatiquement depuis le repo GitHub

## Structure globale

- [x] Dossiers p1/, p2/, p3/ à la racine
- [x] Scripts dans scripts/
- [x] Configs dans confs/ (y compris p1)
- [ ] Pas de dossier bonus/ (optionnel, ne bloque pas la partie mandatory)

---

## Corrections effectuées

### 1. Créer `p1/confs/` — FAIT

Dossier créé avec `.gitkeep` pour respecter l'arborescence attendue par le sujet.

### 2. Corriger `p3/scripts/deploy_app.sh` — FAIT

Le script applique désormais `confs/application.yaml` (la ressource Argo CD Application).
Argo CD synchronise et déploie automatiquement depuis le repo GitHub.

Le flux GitOps :

```
kubectl apply -f confs/application.yaml
  → Argo CD lit le repo GitHub
    → Argo CD déploie automatiquement dans le namespace dev
```

### 3. Repo GitHub vérifié — FAIT

Le repo `github.com/BekxFR/trobert-iot-argocd-app` contient :

- deployment.yaml (wil42/playground:v1)
- service.yaml
- ingress.yaml

Contenu identique aux fichiers dans `p3/confs/` (sans application.yaml qui reste local).

### 4. Démonstration de changement de version (évaluation)

Pendant la soutenance il faut montrer :

1. `curl localhost:8888` → v1
2. Modifier deployment.yaml dans le repo GitHub : v1 → v2
3. Git push
4. Argo CD synchronise automatiquement
5. `curl localhost:8888` → v2
