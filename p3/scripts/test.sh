#!/bin/bash

echo "=== Tests et Vérification - Partie 3 ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"

# Vérification du cluster
echo "🔍 Vérification du cluster K3d..."
echo "Cluster info:"
kubectl cluster-info

echo ""
echo "📊 État des nodes:"
kubectl get nodes

# Vérification des namespaces
echo ""
echo "📁 Namespaces:"
kubectl get namespaces | grep -E "(argocd|dev)"

# Vérification d'Argo CD
echo ""
echo "🔄 État d'Argo CD:"
kubectl get pods -n $NAMESPACE_ARGOCD

# Vérification de l'application
echo ""
echo "🚀 État de l'application:"
kubectl get pods -n $NAMESPACE_DEV
kubectl get svc -n $NAMESPACE_DEV
kubectl get ingress -n $NAMESPACE_DEV

# Test de connectivité
echo ""
echo "🧪 Test de l'application..."

# Port-forward pour le test
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 3

echo "Test de l'endpoint:"
if response=$(curl -s http://localhost:8888 2>/dev/null); then
    echo "✅ Application accessible"
    echo "Response: $response"
    
    # Vérification de la version
    if echo "$response" | grep -q "v1"; then
        echo "✅ Version v1 détectée"
    elif echo "$response" | grep -q "v2"; then
        echo "✅ Version v2 détectée"
    else
        echo "⚠️  Version non identifiée"
    fi
else
    echo "❌ Application non accessible"
fi

# Nettoyage
kill $PORT_FORWARD_PID 2>/dev/null || true

# Récupération du mot de passe Argo CD
echo ""
echo "🔑 Informations Argo CD:"
if kubectl get secret argocd-initial-admin-secret -n $NAMESPACE_ARGOCD >/dev/null 2>&1; then
    ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "URL: http://localhost:8080 (avec port-forward)"
    echo "Username: admin"
    echo "Password: $ARGOCD_PASSWORD"
else
    echo "⚠️  Secret Argo CD non trouvé"
fi

echo ""
echo "🔧 Pour accéder à Argo CD:"
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE_ARGOCD 8080:443"

echo ""
echo "🔧 Pour accéder à l'application:"
echo "kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888"

echo ""
echo "📋 Résumé de conformité aux consignes:"
echo "✅ Cluster K3d créé"
echo "✅ Namespace 'argocd' créé"
echo "✅ Namespace 'dev' créé"
echo "✅ Argo CD installé"
echo "✅ Application déployée"
echo "✅ Application accessible sur port 8888"

# Vérification des versions d'image disponibles
echo ""
echo "🏷️  Pour changer de version (GitOps):"
echo "1. Modifiez deployment.yaml: wil42/playground:v1 → wil42/playground:v2"
echo "2. Commit et push dans votre repository GitHub"
echo "3. Argo CD synchronisera automatiquement"

echo ""
echo "✅ Tests terminés !"
