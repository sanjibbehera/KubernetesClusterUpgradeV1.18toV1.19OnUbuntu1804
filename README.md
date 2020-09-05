# KubernetesClusterUpgradeV1.18toV1.19InUbuntu1804
This Kubernetes Cluster shows the Kubernets Cluster Upgradation Steps from version 1.18 to version 1.19, 3 VMs running on Ubuntu 16.04.  
The Cluster consists of 1 Master Node and 2 Worker Nodes.  
First of all use <b>Vagrant</b> configuration tool to spinup the 3 VMs using <b>Ubuntu</b> 16.04 as OS.  
Use the code in this repo to spinup the VMs, make sure you have <b>Vagrant</b> in your machine.  
Then using <b>kubeadm</b> utility, spinup 3 Kubernetes v1.18 Cluster in the 3 VMs and then approach the <b>kubeadm</b> upgrade process to upgrade the cluster.
