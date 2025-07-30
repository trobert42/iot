#!/bin/bash

echo "=== Installation des outils pour la Partie 3 - K3d et Argo CD ==="

# Mise à jour du système
echo "📦 Mise à jour du système..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Installation des dépendances de base
echo "🔧 Installation des dépendances de base..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    jq \
    ca-certificates \
    gnupg \
    lsb-release

# Installation de Docker
echo "🐳 Installation de Docker..."
# Suppression des anciennes versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Ajout du repository Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configuration Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "⚠️  IMPORTANT: Vous devez vous reconnecter pour que les permissions Docker prennent effet"

# Installation de kubectl
echo "☸️  Installation de kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Installation de k3d
echo "🚀 Installation de k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Installation d'Argo CD CLI
echo "🔄 Installation d'Argo CD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd

# Vérifications
echo ""
echo "🔍 Vérifications des installations..."
echo "Docker version:"
docker --version || echo "❌ Docker non installé"

echo "kubectl version:"
kubectl version --client || echo "❌ kubectl non installé"

echo "k3d version:"
k3d --version || echo "❌ k3d non installé"

echo "Argo CD CLI version:"
argocd version --client || echo "❌ Argo CD CLI non installé"

echo ""
echo "✅ Installation terminée !"
echo ""
echo "⚠️  ATTENTION:"
echo "1. Redémarrez votre session pour que Docker fonctionne sans sudo"
echo "2. Ou utilisez: newgrp docker"
echo ""
echo "Ensuite, lancez: ./setup_cluster.sh"
