require 'yaml'

VMs = YAML.load_file('vagrantVMs.yml')["VMs"]

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  VMs.each do |name, data|
    config.vm.define name do |node|
      node.vm.box = data["box"]
      node.vm.hostname = data["hostname"]

      if data["ip"]
        node.vm.network "private_network",
          ip: data["ip"],
          netmask: data["netmask"] || "255.255.255.0",
          auto_config: true
      else
        node.vm.network "private_network",
          type: "dhcp",
          auto_config: false
      end

      node.vm.provider "virtualbox" do |vb|
        vb.name = name
        vb.memory = data["memory"] if data["memory"]
        vb.cpus = data["cpus"] if data["cpus"]
      end

      if data["file"]
        node.vm.provision "shell", inline: <<-SHELL
          mkdir -p /tmp/tftpboot
          chown vagrant:vagrant /tmp/tftpboot
          chmod 755 /tmp/tftpboot
        SHELL

        data["file"].each do |file|
          node.vm.provision "file",
            source: file["source"],
            destination: file["destination"]
        end
      end

      if data["provision"]
        node.vm.provision "shell",
          path: data["provision"],
          privileged: true
      end
    end
  end
end