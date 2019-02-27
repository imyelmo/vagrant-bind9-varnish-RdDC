# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise32"
# config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 256]
    v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end


  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:808X" will access port 80 on the guest machine.

  config.vm.define :bind9 do |bind9_config|
  	  bind9_config.vm.hostname = "bind9"
  	  bind9_config.vm.network :private_network, ip: "192.168.2.15"
  	  bind9_config.vm.network "forwarded_port", guest: 53, host: 5353
      bind9_config.vm.provision :shell, :path => "bind9.sh"	
      bind9_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'bind9_trace2.pcap'] 
      end    
  end
  
  config.vm.define :varnish1 do |varnish1_config|
  	  varnish1_config.vm.hostname = "varnish1"
  	  varnish1_config.vm.network :private_network, ip: "192.168.2.13"
	  varnish1_config.vm.network :forwarded_port, guest: 80, host: 8080
	  varnish1_config.vm.provision :shell, :path => "varnish1.sh"
	  varnish1_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'varnish1_trace2.pcap'] 
      end  
  end
  
    config.vm.define :varnish2 do |varnish2_config|
  	  varnish2_config.vm.hostname = "varnish2"
  	  varnish2_config.vm.network :private_network, ip: "192.168.2.14"
	  varnish2_config.vm.network :forwarded_port, guest: 80, host: 8081
	  varnish2_config.vm.provision :shell, :path => "varnish2.sh"
	  varnish2_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'varnish2_trace2.pcap'] 
      end  
  end

  config.vm.define :web1 do |web1_config|
    web1_config.vm.hostname = 'web1'
    web1_config.vm.network :private_network, ip: "192.168.2.11"
    web1_config.vm.provision :shell, :path => "web-setup.sh"
    web1_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'web1_trace2.pcap'] 
      end  
  end

  config.vm.define :web2 do |web2_config|
    web2_config.vm.hostname = 'web2'
    web2_config.vm.network :private_network, ip: "192.168.2.12"
    web2_config.vm.provision :shell, :path => "web-setup.sh"
    web2_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'web2_trace2.pcap'] 
      end  
  end

  config.vm.define :firefox do |firefox_config|
    firefox_config.vm.hostname = 'firefox'
    firefox_config.vm.network :private_network, ip: "192.168.2.16"
    firefox_config.ssh.forward_agent = true
	firefox_config.ssh.forward_x11 = true
    firefox_config.vm.provision :shell, :path => "firefox-setup.sh"
    firefox_config.vm.provider :virtualbox do |vb|
      	vb.customize ['modifyvm', :id, '--nictrace2', 'on']
      	vb.customize ['modifyvm', :id, '--nictracefile2', 'firefox_trace2.pcap'] 
      end  
  end
end
