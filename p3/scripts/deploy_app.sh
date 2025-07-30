#!/bin/bash

echo "=== Déploiement de l'application via Argo CD - Partie 3 ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"
GITHUB_REPO="https://github.com/chillion/iot-argocd-app.git"

# Vérification que le cluster est prêt
if ! kubectl get nodes >/dev/null 2>&1; then
    echo "❌ Cluster K3d non accessible. Lancez d'abord: ./setup_cluster.sh"
    exit 1
fi

# Vérification qu'Argo CD est prêt
if ! kubectl get pods -n $NAMESPACE_ARGOCD | grep -q "Running"; then
    echo "❌ Argo CD n'est pas prêt. Attendez quelques minutes et relancez."
    exit 1
fi

echo "🔍 Vérification des namespaces..."
kubectl get namespace $NAMESPACE_ARGOCD $NAMESPACE_DEV

# Déploiement manuel initial (si le repo GitHub n'est pas encore prêt)
echo "🚀 Déploiement manuel de l'application..."
kubectl apply -f confs/deployment.yaml
kubectl apply -f confs/service.yaml
kubectl apply -f confs/ingress.yaml

# Attendre que l'application soit prête
echo "⏳ Attente du démarrage de l'application..."
kubectl wait --for=condition=ready pod -l app=wil-playground -n $NAMESPACE_DEV --timeout=300s

# Configuration de l'application Argo CD (optionnel si repo GitHub disponible)
echo "🔄 Configuration de l'application Argo CD..."
echo "⚠️  IMPORTANT: Modifiez le fichier confs/application.yaml avec votre repository GitHub"
echo "Repository actuel: $GITHUB_REPO"

# Test de l'application
echo "🧪 Test de l'application..."
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 5

if curl -s http://localhost:8888 | grep -q "status"; then
    echo "✅ Application accessible sur http://localhost:8888"
    curl -s http://localhost:8888
else
    echo "⚠️  Application en cours de démarrage..."
fi

# Arrêt du port-forward
kill $PORT_FORWARD_PID 2>/dev/null || true

echo ""
echo "📋 Informations sur l'application:"
echo "- Namespace: $NAMESPACE_DEV"
echo "- Service: wil-playground-service"
echo "- Port: 8888"
echo ""
echo "🔧 Commandes utiles:"
echo "kubectl get pods -n $NAMESPACE_DEV"
echo "kubectl logs -n $NAMESPACE_DEV -l app=wil-playground"
echo "kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888"
echo ""
echo "✅ Déploiement terminé !"
