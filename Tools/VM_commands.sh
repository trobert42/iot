#!/bin/bash
# Script d'installation optimisé pour Ubuntu (EFI)

# Mise à jour système
sudo apt-get update && sudo apt-get upgrade -y

# Installation dépendances de base
sudo apt-get install -y \
    curl wget git build-essential \
    linux-headers-$(uname -r) dkms \
    net-tools gnupg software-properties-common

# Installation VirtualBox (version stable)
sudo apt-get install -y virtualbox virtualbox-ext-pack

# Configuration EFI/Secure Boot
if [ -d /sys/firmware/efi ]; then
    echo "Configuring Secure Boot..."
    sudo apt-get install -y shim-signed
fi

# Installation Vagrant
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y vagrant

# Installation Docker
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Installation outils Kubernetes
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Installation K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Installation Argo CD
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Vérifications finales
echo "=== Vérifications ==="
virtualbox --help >/dev/null && echo "VirtualBox OK" || echo "Erreur VirtualBox"
vagrant --version && echo "Vagrant OK"
docker --version && echo "Docker OK"
k3d --version && echo "K3d OK"
argocd version --client && echo "Argo CD OK"

# Rechargement des groupes utilisateur
newgrp docker <<EONG
echo "Installation terminée ! Redémarrez la session pour les changements complets."
EONG
