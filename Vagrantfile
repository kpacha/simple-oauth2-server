# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "puppetlabs/trusty32"
  config.vm.box_url = "https://vagrantcloud.com/puppetlabs/boxes/ubuntu-14.04-32-puppet/versions/1.0.0/providers/virtualbox.box"
  config.vm.network :forwarded_port, guest: 80, host: 3000
  config.vm.network :forwarded_port, guest: 8080, host: 3030

  config.vm.synced_folder "./", "/vagrant", id: "vagrant-root"

  config.vm.provision :shell, :path => "shell/librarian-puppet.sh"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "site.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.options = "--verbose --environment development"
  end
end
