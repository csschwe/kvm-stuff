# Setup KVM on Ubuntu

https://medium.com/@artem.v.vasilyev/use-ubuntu-cloud-image-with-kvm-1f28c19f82f8 <br>
https://discourse.ubuntu.com/t/building-multipass-images-with-packer/12361 <br>
https://docs.ansible.com/ansible/latest/modules/virt_module.html <br>
https://cloudinit.readthedocs.io/en/latest/index.html <br>


Load an Ubuntu 18.04 server

## Install packages to support KVM and cloud-init
```
sudo apt-get install cloud-utils qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils qemu-utils genisoimage virtinst
```

## Setup a Bridge Interface
### Debian network interfaces
```
# /etc/network/interfaces
# https://wiki.debian.org/BridgeNetworkConnections
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo br0
iface lo inet loopback

# Set up interfaces manually, avoiding conflicts with, e.g., network manager
iface enp7s0 inet manual

# Bridge setup
iface br0 inet static
  bridge_ports enp7s0
    address 192.168.1.50
    broadcast 192.168.1.255
    netmask 255.255.255.0
    gateway 192.168.1.1
```
### Ubuntu netplan
```
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp7s0:
      dhcp4: no
      dhcp6: no
  bridges:
    br0:
      interfaces: [enp7s0]
      dhcp4: no
      addresses: [192.168.1.50/24]
      gateway4: 192.168.1.1
      nameservers:
        search: [home]
        addresses: [192.168.1.1, 8.8.8.8]
```

# Get Hashicorp packer and build custom image
```
cd packer
wget https://releases.hashicorp.com/packer/1.6.6/packer_1.6.6_linux_amd64.zip
unzip packer_1.6.6_linux_amd64.zip
sudo ./packer build ubuntu_build.json

sudo mkdir -p /var/lib/libvirt/images/base

sudo mv output-qemu/packer-qemu /var/lib/libvirt/images/base/ubuntu-20.04-server-cloudimg-amd64-cusomized.qcow2
```

# Build VMs
Modify the network-config file with the correct network information for your vminstance
```
cd cloud-init
rebuild_vms.sh
```
