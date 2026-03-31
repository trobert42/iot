#!/bin/bash

echo "=== Deploiement des applications - P2 ==="

echo "Attente de K3s..."
while ! kubectl get nodes; do
  sleep 5
done

kubectl create namespace apps || true

echo "Deploiement de app1 (1 replica)..."
kubectl apply -f /tmp/confs/app1-deployment.yaml

echo "Deploiement de app2 (3 replicas)..."
kubectl apply -f /tmp/confs/app2-deployment.yaml

echo "Deploiement de app3 (defaut)..."
kubectl apply -f /tmp/confs/app3-deployment.yaml

echo "Configuration des services..."
kubectl apply -f /tmp/confs/app1-service.yaml
kubectl apply -f /tmp/confs/app2-service.yaml
kubectl apply -f /tmp/confs/app3-service.yaml

echo "Configuration de l'Ingress..."
kubectl apply -f /tmp/confs/ingress.yaml

echo "Attente du demarrage des applications..."
kubectl wait --for=condition=ready pod -l app=app1 -n apps --timeout=300s
kubectl wait --for=condition=ready pod -l app=app2 -n apps --timeout=300s
kubectl wait --for=condition=ready pod -l app=app3 -n apps --timeout=300s

kubectl get pods -n apps
kubectl get services -n apps
kubectl get ingress -n apps

echo "[OK] Applications deployees."
echo "  app1.com -> app1"
echo "  app2.com -> app2"
echo "  192.168.56.110 (defaut) -> app3"
