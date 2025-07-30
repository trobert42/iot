#!/bin/bash

echo "=== Test des Applications - Partie 2 ==="

# Fonction pour tester une URL
test_url() {
    local host=$1
    local expected=$2
    
    echo "Test de $host..."
    if [[ "$host" == "default" ]]; then
        result=$(curl -s http://192.168.56.110)
    else
        result=$(curl -s -H "Host: $host" http://192.168.56.110)
    fi
    
    if [[ $result == *"$expected"* ]]; then
        echo "✅ $host : OK"
    else
        echo "❌ $host : ECHEC"
        echo "Résultat obtenu: $result"
    fi
    echo ""
}

# Attendre que les services soient prêts
echo "Attente de la disponibilité des services..."
sleep 10

# Tests
test_url "app1.com" "Application 1"
test_url "app2.com" "Application 2"
test_url "default" "Application 3"

echo "Tests terminés !"

# Affichage du statut du cluster
echo ""
echo "=== Statut du Cluster ==="
kubectl get pods -n apps
echo ""
kubectl get services -n apps
echo ""
kubectl get ingress -n apps
