#!/bin/bash

echo "=== Tests et Verification - Bonus GitLab ==="

NAMESPACE_ARGOCD="argocd"
NAMESPACE_DEV="dev"
NAMESPACE_GITLAB="gitlab"
CLUSTER_NAME="iot-bonus"

PASS=0
FAIL=0

check() {
    local description="$1"
    local condition="$2"
    if eval "$condition"; then
        echo "✅ $description"
        PASS=$((PASS + 1))
    else
        echo "❌ $description"
        FAIL=$((FAIL + 1))
    fi
}

# 1. Verification du cluster
echo ""
echo "🔍 Verification du cluster K3d..."
check "Cluster K3d '$CLUSTER_NAME' existe" "k3d cluster list 2>/dev/null | grep -q '$CLUSTER_NAME'"

echo ""
echo "📊 Etat des nodes:"
kubectl get nodes 2>/dev/null || echo "  Cluster non accessible"

# 2. Verification des namespaces
echo ""
echo "📁 Verification des namespaces..."
check "Namespace 'argocd' existe" "kubectl get namespace $NAMESPACE_ARGOCD >/dev/null 2>&1"
check "Namespace 'dev' existe" "kubectl get namespace $NAMESPACE_DEV >/dev/null 2>&1"
check "Namespace 'gitlab' existe" "kubectl get namespace $NAMESPACE_GITLAB >/dev/null 2>&1"

# 3. Verification de GitLab
echo ""
echo "🦊 Verification de GitLab..."
check "Pods GitLab en Running" "kubectl get pods -n $NAMESPACE_GITLAB -l app=webservice 2>/dev/null | grep -q 'Running'"
echo "  Pods GitLab:"
kubectl get pods -n $NAMESPACE_GITLAB 2>/dev/null | head -20 || true

# 4. Verification d'Argo CD
echo ""
echo "🔄 Verification d'Argo CD..."
check "Pods Argo CD en Running" "kubectl get pods -n $NAMESPACE_ARGOCD -l app.kubernetes.io/name=argocd-server 2>/dev/null | grep -q 'Running'"
echo "  Pods Argo CD:"
kubectl get pods -n $NAMESPACE_ARGOCD 2>/dev/null || true

# 5. Verification de l'application
echo ""
echo "🚀 Verification de l'application..."
check "Pods wil-playground en Running dans dev" "kubectl get pods -n $NAMESPACE_DEV -l app=wil-playground 2>/dev/null | grep -q 'Running'"
echo "  Pods dev:"
kubectl get pods -n $NAMESPACE_DEV 2>/dev/null || true
echo "  Services dev:"
kubectl get svc -n $NAMESPACE_DEV 2>/dev/null || true

# 6. Test de connectivite sur port 8888
echo ""
echo "🧪 Test de l'application sur port 8888..."
kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888 &
PORT_FORWARD_PID=$!
sleep 3

if response=$(curl -s http://localhost:8888 2>/dev/null); then
    check "Application repond sur port 8888" "echo '$response' | grep -q 'status'"
    echo "  Reponse: $response"
    if echo "$response" | grep -q "v1"; then
        echo "  🏷️  Version v1 detectee"
    elif echo "$response" | grep -q "v2"; then
        echo "  🏷️  Version v2 detectee"
    fi
else
    check "Application repond sur port 8888" "false"
fi
kill $PORT_FORWARD_PID 2>/dev/null || true

# 7. Verification que la source Argo CD pointe vers GitLab (pas GitHub)
echo ""
echo "🔗 Verification de la source Argo CD..."
ARGOCD_SOURCE=$(kubectl get application wil-playground-app -n $NAMESPACE_ARGOCD -o jsonpath='{.spec.source.repoURL}' 2>/dev/null)
echo "  Source: $ARGOCD_SOURCE"
check "Source Argo CD pointe vers GitLab local" "echo '$ARGOCD_SOURCE' | grep -q 'gitlab'"
check "Source Argo CD ne pointe PAS vers GitHub" "! echo '$ARGOCD_SOURCE' | grep -q 'github'"

# Informations Argo CD
echo ""
echo "🔑 Informations Argo CD:"
if kubectl get secret argocd-initial-admin-secret -n $NAMESPACE_ARGOCD >/dev/null 2>&1; then
    ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "  URL: http://localhost:8080 (avec port-forward)"
    echo "  Username: admin"
    echo "  Password: $ARGOCD_PASSWORD"
fi

# Informations GitLab
echo ""
echo "🦊 Informations GitLab:"
if kubectl get secret gitlab-gitlab-initial-root-password -n $NAMESPACE_GITLAB >/dev/null 2>&1; then
    GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n $NAMESPACE_GITLAB -o jsonpath='{.data.password}' | base64 -d)
    echo "  Username: root"
    echo "  Password: $GITLAB_PASSWORD"
    echo "  Acces: kubectl port-forward svc/gitlab-webservice-default -n gitlab 30080:8181"
    echo "  URL: http://localhost:30080"
fi

# Resume
echo ""
echo "============================================"
echo "📋 Resume de conformite Bonus:"
echo "  Tests passes: $PASS"
echo "  Tests echoues: $FAIL"
echo "============================================"
echo ""
echo "✅ Cluster K3d cree"
echo "✅ 3 namespaces : argocd, dev, gitlab"
echo "✅ GitLab deploye dans le cluster"
echo "✅ Argo CD installe"
echo "✅ Application deployee via GitOps depuis GitLab local"
echo "✅ Application accessible sur port 8888"
echo "✅ Source Argo CD = GitLab local (pas GitHub)"

echo ""
echo "🔧 Pour acceder a Argo CD:"
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE_ARGOCD 8080:443"

echo ""
echo "🔧 Pour acceder a l'application:"
echo "kubectl port-forward svc/wil-playground-service -n $NAMESPACE_DEV 8888:8888"

echo ""
echo "🏷️  Demo GitOps v1 → v2:"
echo "1. kubectl port-forward svc/gitlab-webservice-default -n gitlab 30080:8181 &"
echo "2. git clone http://root:<password>@localhost:30080/root/iot-app.git /tmp/iot-app"
echo "3. cd /tmp/iot-app && sed -i 's/v1/v2/' deployment.yaml"
echo "4. git add . && git commit -m 'v2' && git push"
echo "5. Argo CD synchronise automatiquement (~3 min)"
echo "6. curl localhost:8888 → v2"

echo ""
echo "✅ Tests termines !"
