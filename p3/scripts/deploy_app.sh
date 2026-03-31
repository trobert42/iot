#!/bin/bash

echo "=== Deploiement via Argo CD - P3 ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"
GITHUB_REPO="https://github.com/BekxFR/trobert-iot-argocd-app.git"

if ! kubectl get nodes >/dev/null 2>&1; then
    echo "[FAIL] Cluster K3d non accessible. Lancez d'abord: ./setup_cluster.sh"
    exit 1
fi

if ! kubectl get pods -n $NAMESPACE_ARGOCD | grep -q "Running"; then
    echo "[FAIL] Argo CD non pret. Attendez et relancez."
    exit 1
fi

kubectl get namespace $NAMESPACE_ARGOCD $NAMESPACE_DEV

echo "Deploiement de l'application (repo: $GITHUB_REPO)..."
kubectl apply -f confs/application.yaml

echo "Attente de la synchronisation Argo CD..."
kubectl wait --for=condition=ready pod -l app=wil-playground -n $NAMESPACE_DEV --timeout=300s

echo "Test de l'application..."
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 5

if curl -s http://localhost:8888 | grep -q "status"; then
    echo "[OK] Application accessible sur http://localhost:8888"
    curl -s http://localhost:8888
else
    echo "Application en cours de demarrage..."
fi

kill $PORT_FORWARD_PID 2>/dev/null || true

echo "[OK] Deploiement termine."
