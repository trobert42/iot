#!/bin/bash

echo "=== Nettoyage de la Partie 3 ==="

CLUSTER_NAME="iot-cluster"

echo "🧹 Suppression du cluster K3d '$CLUSTER_NAME'..."
k3d cluster delete $CLUSTER_NAME

echo "🐳 Nettoyage des ressources Docker..."
docker system prune -f

echo "🔧 Vérification des clusters restants..."
k3d cluster list

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "Pour recréer le cluster:"
echo "./install.sh"
echo "./setup_cluster.sh"
echo "./deploy_app.sh"
