INSTANCE_HOSTNAME=vminstance-1
INSTANCE_IMAGE=${INSTANCE_HOSTNAME}.qcow2
INSTANCE_IMAGE_PATH=/var/lib/libvirt/images/${INSTANCE_HOSTNAME}
BACKING_FILE=/var/lib/libvirt/images/base/ubuntu-20.04-server-cloudimg-amd64-cusomized.qcow2
CLOUD_INIT_FILE=${INSTANCE_HOSTNAME}-cidata.iso
NETWORK_FILE=network-config-${INSTANCE_HOSTNAME}

sudo virsh destroy ${INSTANCE_HOSTNAME}
sudo virsh undefine ${INSTANCE_HOSTNAME}
sudo rm -f ${INSTANCE_IMAGE_PATH}/${INSTANCE_IMAGE} ${INSTANCE_IMAGE_PATH}/${CLOUD_INIT_FILE}

sudo mkdir -p ${INSTANCE_IMAGE_PATH}

cloud-localds --verbose --hostname=${INSTANCE_HOSTNAME} --network-config=${NETWORK_FILE} ${CLOUD_INIT_FILE} user-data

sudo cp ${CLOUD_INIT_FILE} ${INSTANCE_IMAGE_PATH}

sudo qemu-img create \
    -f qcow2 \
    -o backing_file=${BACKING_FILE} ${INSTANCE_IMAGE_PATH}/${INSTANCE_IMAGE} \
    -o backing_fmt=qcow2

sudo qemu-img resize ${INSTANCE_IMAGE_PATH}/${INSTANCE_IMAGE} 20G

sudo virt-install \
    --connect qemu:///system \
    --virt-type kvm \
    --name ${INSTANCE_HOSTNAME} \
    --ram 1024 \
    --vcpus=1 \
    --network bridge=br0 \
    --os-type linux \
    --os-variant ubuntu20.04 \
    --disk path=${INSTANCE_IMAGE_PATH}/${INSTANCE_IMAGE},format=qcow2 \
    --disk ${INSTANCE_IMAGE_PATH}/${CLOUD_INIT_FILE},device=cdrom \
    --import \
    --autostart \
    --noautoconsole
