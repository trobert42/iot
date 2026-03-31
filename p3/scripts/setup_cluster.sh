#!/bin/bash

echo "=== Configuration du cluster K3d - P3 ==="

CLUSTER_NAME="iot-cluster"
NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"

if ! docker ps >/dev/null 2>&1; then
    echo "[FAIL] Docker non accessible. Lancez 'newgrp docker' ou reconnectez-vous."
    exit 1
fi

echo "Nettoyage des clusters existants..."
k3d cluster delete $CLUSTER_NAME 2>/dev/null || true

echo "Creation du cluster K3d '$CLUSTER_NAME'..."
k3d cluster create $CLUSTER_NAME \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --port "8888:8888@loadbalancer" \
    --api-port 6550 \
    --servers 1 \
    --agents 2 \
    --wait

echo "Verification du cluster..."
kubectl cluster-info
kubectl get nodes

echo "Creation des namespaces..."
kubectl create namespace $NAMESPACE_ARGOCD || true
kubectl create namespace $NAMESPACE_DEV || true

echo "Installation d'Argo CD..."
kubectl apply -n $NAMESPACE_ARGOCD -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Attente du demarrage d'Argo CD..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE_ARGOCD --timeout=300s

echo "Configuration de l'acces externe a Argo CD..."
kubectl patch svc argocd-server -n $NAMESPACE_ARGOCD -p '{"spec":{"type":"LoadBalancer"}}'

echo "Recuperation du mot de passe admin Argo CD..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "[OK] Cluster K3d configure."
echo "Argo CD URL: http://localhost:8080"
echo "Argo CD Admin: admin"
echo "Argo CD Password: $ARGOCD_PASSWORD"
echo "Prochaine etape: ./deploy_app.sh"
