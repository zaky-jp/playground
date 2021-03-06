#!/bin/bash
set -eu

# configs
## common
LXD_PROFILE=${LXD_PROFILE:-'default'} # profile which storage and network are added to
REMOTE_USER_NAME=${REMOTE_USER_NAME:-'macos'}
## storage
LVM_VG_NAME=${LVM_VG_NAME:-'ubuntu-vg'} # probably specify default ubuntu volume group upon install
LVM_TP_NAME=${LVM_TP_NAME:-'lxd-tp'} # lvm thin pool name
LXD_POOL_NAME=${LVM_POOL_NAME:-'lvm-tp'} # lxd storage name
## network
PARENT_NIC=${PARENT_NIC:-'enp0s31f6'} # nic macvlan should bind to

# set subuid subgid
echo "root:1000000:1000000000" | sudo tee -a /etc/subuid /etc/subgid >/dev/null
sudo systemctl restart lxd

# allow remote manage
# TODO: modify to safely listen to specific vlan
#ip -j address show ${PARENT_NIC} scope global | jq '.[0].addr_info | .[0] | {"config": {"core.https_address": .local}}' | lxd init --preseed
lxc config set core.https_address=[::]:8443

# setup logical volume for LXD
sudo lvcreate -L 20G --type thin-pool --thinpool ${LVM_TP_NAME} ${LVM_VG_NAME}
lxc storage create ${LXD_POOL_NAME} \
  lvm \
  source=${LVM_VG_NAME} \
  lvm.use_thinpool=true \
  lvm.thinpool_name=${LVM_TP_NAME} \
  lvm.vg.force_reuse=true
lxc profile device add ${LXD_PROFILE} root disk path=/ pool=${LXD_POOL_NAME}

# setup macvlan network
# TODO: stop using eth0 as a default interface
lxc network create lxdmacv0 --type=macvlan parent=${PARENT_NIC}
lxc profile device add default eth0 nic network=lxdmacv0

# setup bridge network
lxc network create lxdbr0 --type=bridge
lxc profile device add default eth1 nic network=lxdbr0

# setup one-time token for remote management
echo "Use below token to \"lxc remote add ${HOSTNAME} ${HOSTNAME}.local\""
lxc config trust add --name ${REMOTE_USER_NAME}

# add ubuntu-minimal as upstream
lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases

