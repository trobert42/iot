#!/bin/bash

echo "=== Installation K3s pour la Partie 2 ==="

# Mise à jour du système
apt-get update -y

# Configuration du firewall
ufw allow 6443/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp

# Installation de K3s en mode server
curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

# Attendre que K3s soit prêt
echo "Attente du démarrage de K3s..."
sleep 30
systemctl status k3s

# Configurer kubectl pour l'utilisateur vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

# Configuration de l'environnement pour vagrant
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

echo "K3s installé avec succès pour la partie 2"
