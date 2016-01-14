# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # Vagrant configuration options are fully documented at
  # https://docs.vagrantup.com.

  config.vm.box = './vagrant-centos/boxes/centos70-x86_64.box'

  # Forwarded port mappings allow access to a specific port on the guest vm
  # from a port on the host machine - to see your vm's port 80, use localhost:8484
  config.vm.network 'forwarded_port', guest: 80, host: 8484 # apache
  config.vm.network 'forwarded_port', guest: 8080, host: 2424 # tomcat
  # config.vm.network "forwarded_port", guest: 3000, host: 8032 # webrick

  # To share an additional folder to the guest VM, state the path on the host
  # to the actual folder, then the path on the guest to mount the folder.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration for VirtualBox:
  config.vm.provider 'virtualbox' do |vb|
    # Display the VirtualBox GUI when booting the machine?
    vb.gui = false
    # Customize the amount of memory on the VM:
    vb.memory = 2048
    vb.cpus = 2
  end

  # Enable provisioning with Ansible
  config.vm.provision 'ansible' do |ansible|
    ansible.verbose = 'vv'
    ansible.groups = {
      'vagrant' => ['default'],
      'all_groups:children' => ['group1'],
    }
    ansible.extra_vars = {
      project_dir: '/vagrant',
      bundle_path: '~/.bundle',
    }
    ansible.playbook = 'provisioning/adrl.yml'
  end
end
