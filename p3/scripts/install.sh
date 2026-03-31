#!/bin/bash

echo "=== Installation P3 - K3d et Argo CD ==="

# Mise a jour du systeme
echo "Mise a jour du systeme..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Dependances de base
echo "Installation des dependances..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    jq \
    ca-certificates \
    gnupg \
    lsb-release

# Docker
echo "Installation de Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# kubectl
echo "Installation de kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# k3d
echo "Installation de k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Argo CD CLI
echo "Installation d'Argo CD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd

# Verifications
echo "Verification des installations..."
docker --version || echo "[FAIL] Docker non installe"
kubectl version --client || echo "[FAIL] kubectl non installe"
k3d --version || echo "[FAIL] k3d non installe"
argocd version --client || echo "[FAIL] Argo CD CLI non installe"

echo "Reconnectez-vous pour Docker sans sudo, ou: newgrp docker"
echo "Puis lancez: ./setup_cluster.sh"
