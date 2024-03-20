#!/usr/bin/env zsh
set -eu

# @fail fast
(( ${+commands[jq]} )) || { echo "error: jq is required for json processing. aborting..."; exit 1; }
(( ${+commands[whiptail]} )) || { echo "error: whiptail is required for interactive select. aborting..."; exit 1; }
(( ${+commands[lxc]} )) || { echo "error: lxc is required to spwan container. aborting..."; exit 1; }
# @end

# @define environment variables
# set log_level
log_level[debug]=1
# configs
(( ${+ceph_config} )) || typeset -A ceph_config
ceph_config[lxc_default_profile]='default'
ceph_config[lxc_container_name]='microceph'
ceph_config[lxc_ceph_profile]='microceph'
ceph_config[base_ubuntu_release]='jammy' # 22.04 LTS
ceph_config[ceph_dashboard_passfile]="/var/snap/microceph/current/conf/password.txt"
typeset -a target_devices
target_devices=(sda sdb sdc sdd)
#(( ${+target_devices} )) || typeset -a target_devices

# @define utility functions
function run(){
  lxc exec "${ceph_config[lxc_container_name]}" -- "$@"
}
# @end

# @define check functions
# @return exit code
function check_lxc_profile_exist() {
  local profile=$1
  lxc profile list -f json | jq -r '[.[].name] | contains(["env.profile"])' >/dev/null
  return $?
}

function check_lxc_container_exist() {
  local name=$1
  echo "debug: checking if $name already exists"
  lxc list -f json | jq --arg name "${name}" -e '[.[].name] | any(.==$name)' >/dev/null
  return $?
}

function check_lxc_container_running() {
  local name=$1
  echo "debug: checking if $name is running"
  lxc list -f json | jq --arg name "${name}" -e '.[] | select(.name == $name) | .status | in({"Running":null})' >/dev/null
  return $?
}

function check_microceph_installed() {
  echo "debug: check microceph is installed to CONTAINER"
  run which microceph 1>/dev/null 2>&1
  return $?
}

function check_microceph_status() {
  run microceph status 1>/dev/null 2>&1
  return $?
}

# @define device selection functions
function set_target_devices() {
  if (( ${#target_devices} )); then
    echo "warning: using predefined target_devices variable"
    return
  fi

  echo "debug: selecting target blockdevices"
  local device_list=$( get_available_devices; )
  target_devices=($( select_devices $device_list; ))
}

function select_devices() {
  local device_list=$*
  whiptail --noitem --nocancel --separate-output\
    --checklist "select disks to be managed by ceph" 15 40 5\
    $device_list\
    3>&1 1>&2 2>&3\
}

function get_available_devices() {
  lsblk -J | jq -rj '.blockdevices | .[] | select(.type == "disk") | " " + .name + " OFF"'
}
# @end

# @define action functions
# @output file changes
function create_temp_password() {
  openssl rand -base64 12 | fold -w 10 | head -1
}

# @define lxd utility functions

function create_lxc_profile() {
  if check_lxc_profile_exist "${ceph_config[lxc_ceph_profile]}"; then
    echo "warning: LXD profile '${ceph_config[lxc_ceph_profile]}' already exists."
    return
  fi

  echo "debug: creating lxd profile"
  lxc profile create "${ceph_config[lxc_ceph_profile]}"
}

function configure_lxc_profile() {
  lxc profile set "${ceph_config[lxc_ceph_profile]}" security.syscalls.intercept.mount true
  attach_block_device_to_profile
}

function attach_block_device_to_profile() {
  if ! (( ${#target_devices} )); then
    echo "error: not enough blockdevices available at target_devices. aborting..."
    exit 1
  fi

  if check_lxc_profile_exist "${ceph_config[lxc_ceph_profile]}"; then
    echo "warning: LXD profile '${ceph_config[lxc_ceph_profile]}' already exists."
    return
  fi

  for d in ${target_devices}; do
    echo "debug: add /dev/${d} to LXD profile"
    lxc profile device add "${ceph_config[lxc_ceph_profile]}" $d unix-block path=/dev/$d
  done
}

function create_lxc_container() {
  if check_lxc_container_exist "${ceph_config[lxc_container_name]}"; then
    echo "warning: ${ceph_config[lxc_container_name]} already exists."
    return
  fi

  echo "debug: creating microceph container"
  lxc init \
  --profile "${ceph_config[lxc_default_profile]}" \
  --profile "${ceph_config[lxc_ceph_profile]}" \
  ubuntu-minimal:"${ceph_config[base_ubuntu_release]}" \
  "${ceph_config[lxc_container_name]}"
}

function start_lxc_container() {
  if check_lxc_container_running "${ceph_config[lxc_container_name]}"; then
    echo "warning: container is already up."
    return
  fi

  echo "debug: start the container and wait for boot"
  lxc start "${ceph_config[lxc_container_name]}"
  sleep 3 # should wait for systemd to start up
  run systemctl is-system-running --wait
}

# @define 'dealing inside container' functions
function install_microceph() {
  if check_microceph_installed; then
    echo "warning: microceph is already installed."
    return
  fi
  run snap install --stable microceph
}

function configure_microceph() {
  if check_microceph_status; then
    echo "warning: microceph is already initialised."
    return
  fi

  echo "info: bootsrapping microceph cluster"; create_microceph_cluster
  echo "debug: wait for configuration to propagate"; sleep 3 # TODO; understand what to wait for
  setup_ceph_dashboard
}

function create_microceph_cluster() {
  run microceph cluster bootstrap
  echo "debug: changing osd crush rule to suit a single instance"
  run ceph osd crush rule rm replicated_rule
  run ceph osd crush rule create-replicated single default osd
}

function setup_ceph_dashboard() {
  run ceph mgr module enable dashboard
  run ceph config set mgr mgr/dashboard/ssl false
  echo "debug: generate one-off password"
  local password=$(create_temp_password)
  builtin echo $(create_temp_password) | run tee "${ceph_config[ceph_dashboard_passfile]}" >/dev/null
  echo "debug: create 'ceph_admin' user with one-off password: ${password}"
  run ceph dashboard ac-user-create --pwd_update_required ceph_admin -i "${ceph_config[ceph_dashboard_passfile]}" administrator >/dev/null
  run ceph config set mgr mgr/dashboard/ssl false
  run ceph mgr module disable dashboard # need to restart dashboard mod
  run ceph mgr module enable dashboard
}

function add_disk_to_ceph() {
  if ! (( ${#target_devices} )); then
    echo "error: no blockdevice available at target_devices variable. aborting..."
    exit 1
  fi

  echo "debug: add blockdevice one by one"
  for d in ${target_devices}; do
    if (read -q "?Confirm wiping /dev/${d} [y/n]"); then
      run microceph disk add --wipe /dev/${d}
    fi
  done
}

function enable_ceph_rgw_gateway() {
  run microceph enable rgw
}

function install_tailscale() {
  curl -fsSL https://tailscale.com/install.sh | run sh
  run tailscale up
  run tailscale serve --bg --https=8443 localhost:8080
  run tailscale serve --bg --https=443 localhost:80
}
# @end

# @run
echo "info: preparing lxc profile"; {
  create_lxc_profile
  #set_target_devices
  configure_lxc_profile
}

echo "info: creating lxc container"; {
  create_lxc_container
}

echo "info: starting lxc container"; {
  start_lxc_container
}

echo "info: bootstrapping microceph"; {
  echo "info: installing microceph..."; install_microceph
  configure_microceph
}

echo "info: adding blockdevices to ceph"; {
  add_disk_to_ceph
}

echo "info: enabling rgw gateway"; {
  enable_ceph_rgw_gateway
}

echo "info: enabling tailscale"; {
  install_tailscale
}
