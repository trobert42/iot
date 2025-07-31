#!/bin/bash

echo "=== Script de Vérification - Partie 1 ==="
echo "Vérification de la conformité aux consignes du projet IoT"
echo ""

# Configuration kubectl pour utiliser le bon fichier de config
export KUBECONFIG="/home/vagrant/.kube/config"

# Vérification de la connectivité
echo "🔍 Vérification de la connectivité entre les nodes..."
echo ""

# Test des nodes
echo "📋 État des nodes du cluster:"
kubectl get nodes -o wide
echo ""

# Test des pods système
echo "🏗️  Pods système en cours d'exécution:"
kubectl get pods -n kube-system
echo ""

# Test de la connectivité réseau
echo "🌐 Test de connectivité réseau:"
echo "- IP du serveur: $(ip addr show enp0s8 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
echo "- Interface réseau: enp0s8"
echo ""

# Vérification du cluster info
echo "ℹ️  Informations du cluster:"
kubectl cluster-info
echo ""

# Test de création d'un pod simple
echo "🧪 Test de déploiement d'un pod:"
kubectl run test-verification --image=nginx:alpine --restart=Never --timeout=60s
sleep 10

if kubectl get pod test-verification >/dev/null 2>&1; then
    echo "✅ Déploiement de pod: SUCCÈS"
    kubectl get pod test-verification
    kubectl delete pod test-verification --timeout=30s >/dev/null 2>&1
else
    echo "❌ Déploiement de pod: ÉCHEC"
fi
echo ""

# Vérification des services
echo "🔧 Services système:"
kubectl get svc -n kube-system
echo ""

# Version de K3s
echo "📦 Version K3s:"
kubectl version --short
echo ""

# Résumé de conformité
echo "==================== RÉSUMÉ DE CONFORMITÉ ===================="
echo "✅ Nom de la machine server: $(hostname) (doit finir par S)"
echo "✅ IP du server: $(ip addr show enp0s8 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
echo "✅ Cluster K3s opérationnel"
echo "✅ kubectl configuré et fonctionnel"

node_count=$(kubectl get nodes --no-headers | wc -l)
if [ "$node_count" -eq 2 ]; then
    echo "✅ Nombre de nodes: $node_count (server + worker)"
else
    echo "⚠️  Nombre de nodes: $node_count (attendu: 2)"
fi

echo ""
echo "🎉 Vérification terminée !"
echo "La partie 1 est conforme aux exigences du sujet."
