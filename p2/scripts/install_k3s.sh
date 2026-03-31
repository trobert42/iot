#!/bin/bash

echo "=== Installation K3s - P2 ==="

apt-get update -y

ufw allow 6443/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp

curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110 --flannel-iface enp0s8

echo "Attente du demarrage de K3s..."
sleep 30
systemctl status k3s

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

echo "[OK] K3s installe pour P2"
