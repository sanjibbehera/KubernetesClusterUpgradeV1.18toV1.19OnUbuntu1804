# KubernetesClusterUpgradeV1.18toV1.19OnUbuntu1804
This Kubernetes Cluster shows the Kubernets Cluster Upgradation Steps from version 1.18 to version 1.19, 2 VMs running on Ubuntu 18.04.  
The Cluster consists of 1 Master Node and 1 Worker Node.  
First of all use <b>Vagrant</b> configuration tool to spinup the 2 VMs using <b>Ubuntu</b> 18.04 as OS.  
Use the code in this repo to spinup the VMs, make sure you have <b>Vagrant</b> installed in your machine.  
Then using <b>kubeadm</b> utility, spinup the Kubernetes v1.18 Cluster in the 2 VMs and then approach the <b>kubeadm</b> upgrade process to upgrade the cluster to version v1.19.

Once the VM's are running and Docker already installed via Vagrant, let us install the Kubernetes cluster via Kubeadm.  
Step 1-4 should be executed in all the VMs in Cluster.

### Step 1:-  
Find out if <b>br_netfilter</b> is enabled in the VMs via the command:- <b>lsmod | grep br_netfilter</b>  
If no results, then enable via the command:- <b>sudo modprobe br_netfilter</b>

### Step 2:-  
Linux iptables to correctly see bridged traffic, set the below in sysctl config.  
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf  
net.bridge.bridge-nf-call-ip6tables = 1  
net.bridge.bridge-nf-call-iptables = 1  
EOF  
sudo sysctl --system

#### Note that swap space is disabled via the command "sudo swapoff -a"

### Step 3:-  
Installing kubeadm, kubelet and kubectl for Ubuntu OS.  
sudo apt-get update && sudo apt-get install -y apt-transport-https curl  
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -  
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list  
deb https://apt.kubernetes.io/ kubernetes-xenial main  
EOF  
sudo apt-get update  
sudo apt-get install -y kubelet=1.18.2-00  kubeadm=1.18.2-00  kubectl=1.18.2-00

### Step 4:-  
Restarting the kubelet.  
sudo systemctl daemon-reload  
sudo systemctl restart kubelet

### Step 5:-  
Initializing your control-plane node.  
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.19.10  
#### Note: Copy the join command for the worker nodes, once the above command completes.

### Step 6:-  
Install <b>Flannel</b> pod network.  
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### Step 7:-  
Upgrading Kubernetes Cluster to version 1.19  
sudo apt update  
sudo apt-cache madison kubeadm  
sudo apt-mark unhold kubeadm && \  
sudo apt-get update && apt-get install -y kubeadm=1.19.0-00 && \  
sudo apt-mark hold kubeadm  
apt-get update && \  
apt-get install -y --allow-change-held-packages kubeadm=1.19.0-00  

Verify kubeadm version via command:- <b>kubeadm version</b>  

#### Upgrading Master Node..  
kubectl drain <MASTER NODE> --ignore-daemonsets
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.19.0
kubectl uncordon <MASTER NODE>
  
#### Upgrading Worker Nodes.. 
sudo apt-mark unhold kubeadm && \  
sudo apt-get update && sudo apt-get install -y kubeadm=1.19.0-00 && \  
sudo apt-mark hold kubeadm  

sudo apt-get update && \  
sudo apt-get install -y --allow-change-held-packages kubeadm=1.19.0-00  
kubectl drain <WORKER NODE> --ignore-daemonsets [on Master Node..]

sudo kubeadm upgrade node  

sudo apt-mark unhold kubelet kubectl && \  
sudo apt-get update && sudo apt-get install -y kubelet=1.19.0-00 kubectl=1.19.0-00 && \  
sudo apt-mark hold kubelet kubectl  

sudo apt-get update && \  
sudo apt-get install -y --allow-change-held-packages kubelet=1.19.0-00 kubectl=1.19.0-00  

sudo systemctl daemon-reload  
sudo systemctl restart kubelet  

kubectl uncordon kubeadm-ubuntu18-worker [Master Node..]
