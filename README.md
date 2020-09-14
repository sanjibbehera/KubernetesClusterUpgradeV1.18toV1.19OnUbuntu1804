# KubernetesClusterUpgradeV1.18toV1.19OnUbuntu1804
    The below information has been referenced from official Kubernetes Documentation site.  
    This Kubernetes Cluster shows the Kubernetes Cluster Upgradation Steps from version 1.18 to version 1.19, 
    2 VMs running on Ubuntu 18.04. The Cluster consists of 1 Master Node and 1 Worker Node.  

    First of all use Vagrant configuration tool to spinup the 2 VMs using Ubuntu 18.04 as OS.  
    Use the code in this repo to spinup the VMs, make sure you have Vagrant and VirtualBox installed in your machine.  
    Then using kubeadm utility, spinup the Kubernetes v1.18 Cluster in the 2 VMs 
    and then approach the kubeadm upgrade process to upgrade the cluster to version v1.19.
    
    The basic assumption of this README is that you have spinup 2 Ubntu VMs using the repo code and 
    are ready to spinup the k8s cluster using Kubeadm.

Once the VM's are running and Docker already installed via Vagrant configuration scripts, let us install the Kubernetes cluster via Kubeadm.  
Step 1-4 should be executed in all the VMs in Cluster.

### Step 1:-  
Find out if <b>br_netfilter</b> is enabled in the VMs via the command:- <b>lsmod | grep br_netfilter</b>  
If no results, then enable via the command:- <b>sudo modprobe br_netfilter</b>  
<b>Why it is required</b>  
br_netfilter is the module required to enable transparent masquerading and to facilitate Virtual Extensible LAN (VxLAN) traffic for communication between Kubernetes pods across the cluster.

### Step 2:-  
Linux iptables to correctly see bridged traffic, set the below in sysctl config.  
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf  
net.bridge.bridge-nf-call-ip6tables = 1  
net.bridge.bridge-nf-call-iptables = 1  
EOF  
sudo sysctl --system

<b>Note that swap space should be disabled..</b>  
Disable Swap:- "sudo swapoff -a"  
<b>Why it is required</b>  
The Kubernetes scheduler determines the best available node on which to deploy newly created pods.   
If memory swapping is allowed to occur on a host system, this can lead to performance and stability issues within Kubernetes.  
For this reason, Kubernetes requires that you disable swap in the host system.

### Step 3:-  
Installing kubeadm, kubelet and kubectl version 1.18.2 for Ubuntu OS.  
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
Initializing your control-plane node using the below command [This command should be executed in Master Node].  
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.19.10  
#### Note: Copy the join command for the worker nodes, once the above command completes.

### Step 6:-  
Install <b>Flannel</b> pod network.  
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### Step 7: Take etcd backup to be on safer side..  
Download the <b>etcdctl</b> binary from the URL "https://github.com/coreos/etcd/releases/download/v<Version No>/etcd-v<Version No>-linux-amd64.tar.gz" to connect to ETCD DB of the cluster.  
<b>Note that you find the etcd version running inside the cluster via cmd: docker images</b>  

<b>Create some keys in the etcd DB before taking backup.</b>

    ETCDCTL_API=3  etcdctl --endpoints=https://127.0.0.1:2379 \  
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \  
    --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \  
    --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \  
    put foo bar
    
<b>Run the below cmd to take etcd backup.</b>

    ETCDCTL_API=3  etcdctl --endpoints=https://127.0.0.1:2379 \  
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \  
    --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \  
    --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \  
    snapshot save /tmp/etcd-snapshot-latest-sanjib.db
    
    Verify the backup file exists under /tmp directory and as well verify the backup is not corrupt via the below cmd.  
    ETCDCTL_API=3 etcdctl snapshot status -w table /tmp/etcd-snapshot-latest-sanjib.db

<b> Restore cmd for the etcd DB if there is a need to restoration. </b>  

    ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \  
     --name=master \  
     --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \  
     --data-dir /var/lib/etcd-from-backup \  
     --initial-cluster=master=https://127.0.0.1:2380 \  
     --initial-cluster-token=etcd-cluster-1 \  
     --initial-advertise-peer-urls=https://127.0.0.1:2380 \  
     snapshot restore /tmp/etcd-snapshot-latest-sanjib.db
     
<b> Make the below necessary changes in etcd.yaml in the manifests folder.</b>
    
    --data-dir=/var/lib/etcd-from-backup
    - mountPath: /var/lib/etcd-from-backup [under volumeMounts section]
    path: /var/lib/etcd [under hostPath section]

<b>After restoring fetch the foo key and its value from the restored etcd DB, to verify DB.</b>  

    ETCDCTL_API=3  etcdctl --endpoints=https://127.0.0.1:2379 \  
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \  
    --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \  
    --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \  
    get foo
     

### Step 8:-  
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
Upgrade kubeadm in Worker Node.  
sudo apt-mark unhold kubeadm && \  
sudo apt-get update && sudo apt-get install -y kubeadm=1.19.0-00 && \  
sudo apt-mark hold kubeadm  

sudo apt-get update && \  
sudo apt-get install -y --allow-change-held-packages kubeadm=1.19.0-00  
kubectl drain <WORKER NODE> --ignore-daemonsets [This cmd should be run on Master Node..]

sudo kubeadm upgrade node  

Upgrade the kubelet and kubectl on the worker nodes.  
sudo apt-mark unhold kubelet kubectl && \  
sudo apt-get update && sudo apt-get install -y kubelet=1.19.0-00 kubectl=1.19.0-00 && \  
sudo apt-mark hold kubelet kubectl  

sudo apt-get update && \  
sudo apt-get install -y --allow-change-held-packages kubelet=1.19.0-00 kubectl=1.19.0-00  

sudo systemctl daemon-reload  
sudo systemctl restart kubelet  

kubectl uncordon kubeadm-ubuntu18-worker [This cmd should be run on Master Node..]
