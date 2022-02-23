#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sudo bash -c "echo '${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local' >> /etc/hosts"

# Update /etc/hosts about other hosts
sudo cat >> /etc/hosts <<EOF
192.168.19.10  kubeadm-ubuntu1804-master
192.168.19.11  kubeadm-ubuntu1804-worker
EOF
