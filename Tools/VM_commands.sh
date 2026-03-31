#!/bin/bash
# Script d'installation pour Debian (VM d'évaluation IoT)
# Installe tous les prérequis pour les parties p1, p2, p3 et bonus
#
# Usage:
#   ./VM_commands.sh              # Installation de base (obligatoire)
#   ./VM_commands.sh --with-ide   # + VSCode et Claude Code (optionnel)

set -e

INSTALL_IDE=false
if [ "$1" = "--with-ide" ]; then
    INSTALL_IDE=true
fi

echo "=== Installation des prérequis IoT (Debian) ==="

# Mise à jour système
sudo apt-get update && sudo apt-get upgrade -y

# Installation dépendances de base
sudo apt-get install -y \
    curl wget git make build-essential \
    linux-headers-$(uname -r) dkms \
    net-tools gnupg lsb-release \
    software-properties-common apt-transport-https ca-certificates

# ============================================================
# VirtualBox (requis pour p1, p2)
# ============================================================
sudo apt-get install -y virtualbox
# Acceptation auto de la licence ext-pack
echo "virtualbox-ext-pack virtualbox-ext-pack/license select true" | \
    sudo debconf-set-selections
sudo apt-get install -y virtualbox-ext-pack

# Configuration EFI/Secure Boot
if [ -d /sys/firmware/efi ]; then
    echo "Configuration Secure Boot..."
    sudo apt-get install -y shim-signed
fi

# ============================================================
# Vagrant (requis pour p1, p2)
# ============================================================
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y vagrant

# ============================================================
# Docker (requis pour p3, bonus)
# ============================================================
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# ============================================================
# kubectl (requis pour p1, p2, p3, bonus)
# ============================================================
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# ============================================================
# K3d (requis pour p3, bonus)
# ============================================================
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# ============================================================
# Argo CD CLI (requis pour p3, bonus)
# ============================================================
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# ============================================================
# Helm (requis pour bonus — déploiement GitLab)
# ============================================================
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ============================================================
# Optionnel : VSCode + Claude Code
# ============================================================
if [ "$INSTALL_IDE" = true ]; then
    echo "=== Installation VSCode + Claude Code ==="

    # VSCode
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | \
        sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
        sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt-get update && sudo apt-get install -y code

    # Node.js 22 LTS (requis pour Claude Code)
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs

    # Claude Code CLI
    sudo npm install -g @anthropic-ai/claude-code

    echo "VSCode et Claude Code installés."
    echo "  → Lancer VSCode : code"
    echo "  → Lancer Claude Code : claude"
fi

# ============================================================
# Vérifications finales
# ============================================================
echo ""
echo "=== Vérifications ==="
virtualbox --help >/dev/null 2>&1 && echo "[OK] VirtualBox" || echo "[FAIL] VirtualBox"
vagrant --version >/dev/null 2>&1 && echo "[OK] Vagrant" || echo "[FAIL] Vagrant"
docker --version >/dev/null 2>&1 && echo "[OK] Docker" || echo "[FAIL] Docker"
kubectl version --client >/dev/null 2>&1 && echo "[OK] kubectl" || echo "[FAIL] kubectl"
k3d --version >/dev/null 2>&1 && echo "[OK] K3d" || echo "[FAIL] K3d"
argocd version --client >/dev/null 2>&1 && echo "[OK] Argo CD CLI" || echo "[FAIL] Argo CD CLI"
helm version --short >/dev/null 2>&1 && echo "[OK] Helm" || echo "[FAIL] Helm"

if [ "$INSTALL_IDE" = true ]; then
    code --version >/dev/null 2>&1 && echo "[OK] VSCode" || echo "[FAIL] VSCode"
    claude --version >/dev/null 2>&1 && echo "[OK] Claude Code" || echo "[FAIL] Claude Code"
fi

echo ""
echo "Installation terminée !"
echo "NOTE: Redémarrez la session ou exécutez 'newgrp docker' pour utiliser Docker sans sudo."
