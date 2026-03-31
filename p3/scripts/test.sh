#!/bin/bash

echo "=== Tests - P3 ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"

echo "Cluster info:"
kubectl cluster-info
kubectl get nodes

echo "Namespaces:"
kubectl get namespaces | grep -E "(argocd|dev)"

echo "Argo CD pods:"
kubectl get pods -n $NAMESPACE_ARGOCD

echo "Application:"
kubectl get pods -n $NAMESPACE_DEV
kubectl get svc -n $NAMESPACE_DEV
kubectl get ingress -n $NAMESPACE_DEV

echo "Test de l'application..."
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 3

if response=$(curl -s http://localhost:8888 2>/dev/null); then
    echo "[OK] Application accessible"
    echo "Response: $response"
    if echo "$response" | grep -q "v1"; then
        echo "Version v1 detectee"
    elif echo "$response" | grep -q "v2"; then
        echo "Version v2 detectee"
    else
        echo "Version non identifiee"
    fi
else
    echo "[FAIL] Application non accessible"
fi

kill $PORT_FORWARD_PID 2>/dev/null || true

echo "Argo CD credentials:"
if kubectl get secret argocd-initial-admin-secret -n $NAMESPACE_ARGOCD >/dev/null 2>&1; then
    ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "  URL: http://localhost:8080 (avec port-forward)"
    echo "  Username: admin"
    echo "  Password: $ARGOCD_PASSWORD"
else
    echo "  [FAIL] Secret Argo CD non trouve"
fi
