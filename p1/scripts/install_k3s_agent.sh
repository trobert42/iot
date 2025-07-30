#!/bin/bash

echo "=== Installation K3s Agent - Partie 1 ==="

# Mise à jour du système
apt-get update -y

# Configuration du firewall
ufw allow 6443/tcp
ufw allow 22/tcp

# Test de connectivité SSH vers le serveur
echo "Test de connectivité SSH vers le serveur..."
ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no vagrant@192.168.56.110 "exit 0"

# Attendre que le serveur soit prêt
echo "Attente de la disponibilité du serveur K3s..."
sleep 15

# Récupération du token depuis le serveur
echo "Récupération du token K3s..."
K3S_TOKEN=$(ssh -i /home/vagrant/.ssh/id_rsa vagrant@192.168.56.110 "sudo cat /var/lib/rancher/k3s/server/node-token")

if [ -z "$K3S_TOKEN" ]; then
  echo "Erreur: Impossible de récupérer le token K3s"
  exit 1
fi

echo "Token récupéré avec succès"

# Installation de K3s en mode agent
echo "Installation de K3s en mode agent..."
curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=$K3S_TOKEN \
  sh -s - agent \
  --node-ip 192.168.56.111 \
  --flannel-iface eth1

# Vérification du statut
systemctl enable k3s-agent
systemctl status k3s-agent

echo "K3s agent installé avec succès et connecté au cluster"