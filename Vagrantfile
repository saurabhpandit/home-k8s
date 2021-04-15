
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Set cpus to half number of host cpus
cpus = case RbConfig::CONFIG["host_os"]
  when /darwin/ then `sysctl -n hw.ncpu`.to_i / 2
  when /linux/ then `nproc`.to_i / 2
  else 2
end

NODES_NUM = 2
IP_BASE_PRIVATE = "192.168.1."

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  (1..NODES_NUM).each do |i|
    config.vm.define "k8s-node-#{i + 29}" do |config|

      hostname = "k8s-node-#{i + 29}"

      memory = case hostname
        when "k8s-node-30" then 2048
        else 2048
      end

      config.vm.box = "bento/ubuntu-20.04"
      config.vm.network "public_network", ip: "#{IP_BASE_PRIVATE}#{i + 29}"
      config.vm.hostname = hostname
      config.vm.provider "virtualbox"
      config.vm.provider :virtualbox do |v|
        v.linked_clone = true
        v.gui = false
        v.customize [
          'modifyvm', :id,
          "--cpus", cpus,
          "--memory", memory,
          "--name", hostname,
          "--ioapic", "on",
          '--audio', 'none',
          "--uartmode1", "file", File::NULL,
        ]

        # Create a block device for Longhorn on the worker nodes
        if hostname != "k8s-node-30"
          disk = "./"+hostname+"-block.vdi"
          unless File.exist?(disk)
            v.customize [
              "createhd",
              "--filename", disk,
              "--variant", "Fixed",
              "--size", 1024*5
            ]
          end
          v.customize [
            "storageattach", :id,
            "--storagectl", "SATA Controller",
            "--port", 2,
            "--device", 0,
            "--type", "hdd",
            "--medium", disk
          ]
        end
      end
    end
  end
end
