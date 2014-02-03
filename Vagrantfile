Vagrant.configure("1") do |config|
	config.vm.box = "precise32"
	config.vm.forward_port 80, 3000
	config.vm.forward_port 3306, 33060
	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = "provision/manifests"
		puppet.module_path = "provision/modules"
		puppet.manifest_file = "init.pp"
	end
end

Vagrant.configure("2") do |config|
	config.vm.synced_folder "./", "/vagrant", id: "vagrant-root",
	    owner: "vagrant",
	    group: "www-data",
	    mount_options: ["dmode=775,fmode=664"]
end