#!/bin/bash

echo "=== Verification - P1 ==="

export KUBECONFIG="/home/vagrant/.kube/config"

echo "Nodes:"
kubectl get nodes -o wide

echo "Pods systeme:"
kubectl get pods -n kube-system

echo "Reseau:"
echo "  IP serveur: $(ip addr show enp0s8 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
echo "  Interface: enp0s8"

echo "Cluster info:"
kubectl cluster-info

echo "Test deploiement pod..."
kubectl run test-verification --image=nginx:alpine --restart=Never --timeout=60s
sleep 10

if kubectl get pod test-verification >/dev/null 2>&1; then
    echo "[PASS] Deploiement de pod"
    kubectl get pod test-verification
    kubectl delete pod test-verification --timeout=30s >/dev/null 2>&1
else
    echo "[FAIL] Deploiement de pod"
fi

echo "Services systeme:"
kubectl get svc -n kube-system

echo "Version K3s:"
kubectl version --short

node_count=$(kubectl get nodes --no-headers | wc -l)
if [ "$node_count" -eq 2 ]; then
    echo "[PASS] Nodes: $node_count (server + worker)"
else
    echo "[FAIL] Nodes: $node_count (attendu: 2)"
fi
