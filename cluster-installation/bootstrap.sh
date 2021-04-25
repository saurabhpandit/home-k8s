#!/bin/bash
set -euo pipefail

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Upgrade"
apt-get update && apt-get upgrade -y

echo "[TASK 3] Stop and Disable firewall"
systemctl disable --now ufw

echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

echo "[TASK 6] Install containerd runtime"
apt update -qq
apt install -qq -y containerd apt-transport-https
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "[TASK 7] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "[TASK 8] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm=1.20.5-00 kubelet=1.20.5-00 kubectl=1.20.5-00

echo "[TASK 9] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 10] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root
#echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 11] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.1.30   kmaster.example.com     kmaster
192.168.1.31   kworker1.example.com    kworker1
EOF
