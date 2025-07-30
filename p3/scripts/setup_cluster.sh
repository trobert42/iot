#!/bin/bash

echo "=== Configuration du cluster K3d - Partie 3 ==="

CLUSTER_NAME="iot-cluster"
NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"

# Vérification que Docker fonctionne
if ! docker ps >/dev/null 2>&1; then
    echo "❌ Docker n'est pas accessible. Exécutez 'newgrp docker' ou redémarrez votre session."
    exit 1
fi

# Suppression du cluster existant s'il existe
echo "🧹 Nettoyage des clusters existants..."
k3d cluster delete $CLUSTER_NAME 2>/dev/null || true

# Création du cluster K3d
echo "🚀 Création du cluster K3d '$CLUSTER_NAME'..."
k3d cluster create $CLUSTER_NAME \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --port "8888:8888@loadbalancer" \
    --api-port 6550 \
    --servers 1 \
    --agents 2 \
    --wait

# Vérification du cluster
echo "🔍 Vérification du cluster..."
kubectl cluster-info
kubectl get nodes

# Création des namespaces
echo "📁 Création des namespaces..."
kubectl create namespace $NAMESPACE_ARGOCD || true
kubectl create namespace $NAMESPACE_DEV || true

# Installation d'Argo CD
echo "🔄 Installation d'Argo CD..."
kubectl apply -n $NAMESPACE_ARGOCD -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que Argo CD soit prêt
echo "⏳ Attente du démarrage d'Argo CD..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE_ARGOCD --timeout=300s

# Configuration d'Argo CD pour l'accès externe
echo "🌐 Configuration de l'accès externe à Argo CD..."
kubectl patch svc argocd-server -n $NAMESPACE_ARGOCD -p '{"spec":{"type":"LoadBalancer"}}'

# Récupération du mot de passe admin initial
echo "🔑 Récupération du mot de passe admin Argo CD..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ Cluster K3d configuré avec succès !"
echo ""
echo "📋 Informations importantes:"
echo "- Cluster: $CLUSTER_NAME"
echo "- Namespaces: $NAMESPACE_ARGOCD, $NAMESPACE_DEV"
echo "- Argo CD URL: http://localhost:8080"
echo "- Argo CD Admin: admin"
echo "- Argo CD Password: $ARGOCD_PASSWORD"
echo ""
echo "🔧 Commandes utiles:"
echo "kubectl get pods -n $NAMESPACE_ARGOCD"
echo "kubectl get pods -n $NAMESPACE_DEV"
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE_ARGOCD 8080:443"
echo ""
echo "Prochaine étape: ./deploy_app.sh"
