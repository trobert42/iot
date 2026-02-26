#!/bin/bash

echo "=== Configuration du cluster K3d - Bonus GitLab ==="

CLUSTER_NAME="iot-bonus"
NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"
NAMESPACE_GITLAB="gitlab"

# Verification que Docker fonctionne
if ! docker ps >/dev/null 2>&1; then
    echo "❌ Docker n'est pas accessible. Executez 'newgrp docker' ou redemarrez votre session."
    exit 1
fi

# Suppression du cluster existant s'il existe
echo "🧹 Nettoyage des clusters existants..."
k3d cluster delete $CLUSTER_NAME 2>/dev/null || true

# Creation du cluster K3d
echo "🚀 Creation du cluster K3d '$CLUSTER_NAME'..."
k3d cluster create $CLUSTER_NAME \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --port "8888:8888@loadbalancer" \
    --api-port 6550 \
    --servers 1 \
    --agents 2 \
    --wait

# Verification du cluster
echo "🔍 Verification du cluster..."
kubectl cluster-info
kubectl get nodes

# Creation des 3 namespaces
echo "📁 Creation des namespaces..."
kubectl create namespace $NAMESPACE_ARGOCD || true
kubectl create namespace $NAMESPACE_DEV || true
kubectl create namespace $NAMESPACE_GITLAB || true

# Installation d'Argo CD
echo "🔄 Installation d'Argo CD..."
kubectl apply -n $NAMESPACE_ARGOCD -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que Argo CD soit pret
echo "⏳ Attente du demarrage d'Argo CD..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE_ARGOCD --timeout=300s

# Configuration d'Argo CD pour l'acces externe
echo "🌐 Configuration de l'acces externe a Argo CD..."
kubectl patch svc argocd-server -n $NAMESPACE_ARGOCD -p '{"spec":{"type":"LoadBalancer"}}'

# Recuperation du mot de passe admin initial
echo "🔑 Recuperation du mot de passe admin Argo CD..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ Cluster K3d configure avec succes !"
echo ""
echo "📋 Informations importantes:"
echo "- Cluster: $CLUSTER_NAME"
echo "- Namespaces: $NAMESPACE_ARGOCD, $NAMESPACE_DEV, $NAMESPACE_GITLAB"
echo "- Argo CD URL: http://localhost:8080"
echo "- Argo CD Admin: admin"
echo "- Argo CD Password: $ARGOCD_PASSWORD"
echo ""
echo "Prochaine etape : ./scripts/deploy_gitlab.sh"
