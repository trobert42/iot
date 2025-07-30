#!/bin/bash

echo "=== Déploiement des applications pour la Partie 2 ==="

# Attendre que K3s soit complètement prêt
echo "Attente de la disponibilité de K3s..."
while ! kubectl get nodes; do
  sleep 5
done

# Créer le namespace pour les applications
kubectl create namespace apps || true

echo "Déploiement de app1 (1 replica)..."
kubectl apply -f /tmp/confs/app1-deployment.yaml

echo "Déploiement de app2 (3 replicas)..."
kubectl apply -f /tmp/confs/app2-deployment.yaml

echo "Déploiement de app3 (application par défaut)..."
kubectl apply -f /tmp/confs/app3-deployment.yaml

echo "Configuration des services..."
kubectl apply -f /tmp/confs/app1-service.yaml
kubectl apply -f /tmp/confs/app2-service.yaml
kubectl apply -f /tmp/confs/app3-service.yaml

echo "Configuration de l'Ingress..."
kubectl apply -f /tmp/confs/ingress.yaml

# Attendre que les pods soient prêts
echo "Attente du démarrage des applications..."
kubectl wait --for=condition=ready pod -l app=app1 -n apps --timeout=300s
kubectl wait --for=condition=ready pod -l app=app2 -n apps --timeout=300s
kubectl wait --for=condition=ready pod -l app=app3 -n apps --timeout=300s

echo "Vérification du statut des applications..."
kubectl get pods -n apps
kubectl get services -n apps
kubectl get ingress -n apps

echo "Configuration terminée ! Vous pouvez maintenant tester les applications."
echo "- app1.com -> app1"
echo "- app2.com -> app2"  
echo "- 192.168.56.110 (par défaut) -> app3"
