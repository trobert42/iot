#!/bin/bash

echo "=== Installation K3s Server - P1 ==="

apt-get update -y

ufw allow 6443/tcp
ufw allow 22/tcp

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --flannel-iface enp0s8

echo "Attente du demarrage de K3s..."
sleep 30
systemctl enable k3s
systemctl status k3s

sudo chmod 644 /var/lib/rancher/k3s/server/node-token

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

export KUBECONFIG=/home/vagrant/.kube/config
export k=kubectl

echo "[OK] K3s server installe (controller mode)"
echo "Cluster: 192.168.56.110:6443"
kubectl get nodes -o wide