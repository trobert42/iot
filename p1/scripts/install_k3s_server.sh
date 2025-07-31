#!/bin/bash

echo "=== Installation K3s Server - Partie 1 ==="

# Mise à jour du système
apt-get update -y

# Configuration du firewall
ufw allow 6443/tcp
ufw allow 22/tcp

# Installation de K3s en mode server (controller mode)
curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --flannel-iface enp0s8

# Attendre que K3s soit prêt
echo "Attente du démarrage de K3s..."
sleep 30
systemctl enable k3s
systemctl status k3s

# Rendre le token accessible pour l'agent
sudo chmod 644 /var/lib/rancher/k3s/server/node-token

# Configurer kubectl pour l'utilisateur vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

# Configuration de l'environnement pour vagrant
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

# Recharger la configuration bash pour l'utilisateur actuel
export KUBECONFIG=/home/vagrant/.kube/config
export k=kubectl

echo "K3s server installé avec succès en mode controller"
echo "Cluster accessible depuis 192.168.56.110:6443"

# Test final
echo "=== Test de connectivité ==="
kubectl get nodes -o wide