#!/bin/bash

echo "=== Installation K3s Agent - P1 ==="

apt-get update -y

ufw allow 6443/tcp
ufw allow 22/tcp

echo "Test SSH vers le serveur..."
ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR vagrant@192.168.56.110 "exit 0"

echo "Attente du serveur K3s..."
sleep 15

echo "Recuperation du token K3s..."
K3S_TOKEN=$(ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR vagrant@192.168.56.110 "sudo cat /var/lib/rancher/k3s/server/node-token")

if [ -z "$K3S_TOKEN" ]; then
  echo "[FAIL] Impossible de recuperer le token K3s"
  exit 1
fi

echo "[OK] Token recupere"

echo "Installation de K3s agent..."
curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=$K3S_TOKEN \
  sh -s - agent \
  --node-ip 192.168.56.111 \
  --flannel-iface enp0s8

echo "Attente du demarrage de K3s agent..."
sleep 30
systemctl enable k3s-agent
systemctl status k3s-agent

echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

export KUBECONFIG=/home/vagrant/.kube/config
export k=kubectl

echo "[OK] K3s agent installe et connecte au cluster"