IP_NW = "192.168.19."
KUBERNETES_MASTER_IP = 10
KUBERNETES_WORKER_IP = 11

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"
	config.vm.box_version = "20200901.0.0"
	config.ssh.forward_agent = true
    config.vm.define "kubeadm-ubuntu18-master" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubeadm-ubuntu18-master"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kubeadm-ubuntu18-master"
        node.vm.network :private_network, ip: IP_NW + "#{KUBERNETES_MASTER_IP}"
        node.vm.network "forwarded_port", guest: 22, host: 3390

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/setup-hosts.sh" do |s|
            s.args = ["eth1"]
        end
        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
		node.vm.provision "installDocker", type: "shell", :path => "ubuntu/install-docker.sh"
    end
    config.vm.define "kubeadm-ubuntu18-worker" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubeadm-ubuntu18-worker"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kubeadm-ubuntu18-worker"
        node.vm.network :private_network, ip: IP_NW + "#{KUBERNETES_WORKER_IP}"
        node.vm.network "forwarded_port", guest: 22, host: 3488

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/setup-hosts.sh" do |s|
            s.args = ["eth1"]
        end
        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
		node.vm.provision "installDocker", type: "shell", :path => "ubuntu/install-docker.sh"
    end
end