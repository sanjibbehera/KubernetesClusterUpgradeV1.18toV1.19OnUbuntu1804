# KubernetesClusterUpgradeV1.18toV1.19OnUbuntu1804
This Kubernetes Cluster shows the Kubernets Cluster Upgradation Steps from version 1.18 to version 1.19, 2 VMs running on Ubuntu 18.04.  
The Cluster consists of 1 Master Node and 1 Worker Node.  
First of all use <b>Vagrant</b> configuration tool to spinup the 2 VMs using <b>Ubuntu</b> 18.04 as OS.  
Use the code in this repo to spinup the VMs, make sure you have <b>Vagrant</b> in your machine.  
Then using <b>kubeadm</b> utility, spinup the Kubernetes v1.18 Cluster in the 2 VMs and then approach the <b>kubeadm</b> upgrade process to upgrade the cluster to version v1.19.
