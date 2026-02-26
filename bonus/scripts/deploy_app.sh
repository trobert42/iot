#!/bin/bash

echo "=== Deploiement de l'application via Argo CD - Bonus GitLab ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BONUS_DIR="$(dirname "$SCRIPT_DIR")"

# Verification que le cluster est pret
if ! kubectl get nodes >/dev/null 2>&1; then
    echo "❌ Cluster K3d non accessible. Lancez d'abord : ./scripts/setup_cluster.sh"
    exit 1
fi

# Verification qu'Argo CD est pret
if ! kubectl get pods -n $NAMESPACE_ARGOCD | grep -q "Running"; then
    echo "❌ Argo CD n'est pas pret. Attendez quelques minutes et relancez."
    exit 1
fi

echo "🔍 Verification des namespaces..."
kubectl get namespace $NAMESPACE_ARGOCD $NAMESPACE_DEV

# Deploiement via Argo CD Application
echo "🚀 Deploiement de l'application via Argo CD..."
echo "Source : GitLab local (gitlab-webservice-default.gitlab.svc.cluster.local)"
kubectl apply -f "$BONUS_DIR/confs/application.yaml"

# Attendre que Argo CD synchronise et deploie l'application
echo "⏳ Attente de la synchronisation Argo CD..."
echo "Argo CD va automatiquement deployer depuis le GitLab local dans le namespace $NAMESPACE_DEV"
kubectl wait --for=condition=ready pod -l app=wil-playground -n $NAMESPACE_DEV --timeout=300s

# Test de l'application
echo "🧪 Test de l'application..."
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 5

if curl -s http://localhost:8888 | grep -q "status"; then
    echo "✅ Application accessible sur http://localhost:8888"
    curl -s http://localhost:8888
else
    echo "⚠️  Application en cours de demarrage..."
fi

# Arret du port-forward
kill $PORT_FORWARD_PID 2>/dev/null || true

echo ""
echo "📋 Informations sur l'application:"
echo "- Namespace: $NAMESPACE_DEV"
echo "- Service: wil-playground-service"
echo "- Port: 8888"
echo "- Source: GitLab local (pas GitHub)"
echo ""
echo "🔧 Commandes utiles:"
echo "kubectl get pods -n $NAMESPACE_DEV"
echo "kubectl logs -n $NAMESPACE_DEV -l app=wil-playground"
echo "kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888"
echo ""
echo "✅ Deploiement termine !"
