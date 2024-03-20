#!/usr/bin/env zsh
set -eu
#log_level[debug]=1 # enable debug

# @fail fast
(( $+commands[brew] )) || {
  echo "error: brew is not installed"
  exit 1
}
# @end

# @define environment variables
local LIMA_CONTAINER_NAME="default"
# @end

# @define check functions
function check_lima_container_exist() {
  limactl list --format '{{.Name}}' | grep -q "${LIMA_CONTAINER_NAME}"
  return $?
}

function check_docker_context_exist() {
  docker context ls --format '{{.Name}}' | grep -q "${LIMA_CONTAINER_NAME}"
  return $?
}
# @end

# @define install functions
function install_lima() {
  if (( $+commands[limactl] )); then
    echo "debug: limactl is already installed"
    return
  fi
  echo "info: installing lima..."
  brew install lima
  limactl completion zsh > $(brew --prefix)/share/zsh/site-functions/_limactl
}

function install_docker_cli() {
  if (( $+commands[docker] )); then
    echo "debug: docker cli is already installed"
    return
  fi
  echo "info: installing docker cli..."
  brew install docker # not to be confused with brew install --cask docker
}
# @end

# @define configure functions
function create_lima_container() {
  if check_lima_container_exist; then
    echo "debug: lima container already exists"
    return
  fi
  limactl create --name="${LIMA_CONTAINER_NAME}" \
    --cpus=4 --memory=4 \
    --vm-type=vz --mount-type=virtiofs --network=vzNAT --rosetta \
    template://docker
}

function create_docker_context() {
  if check_docker_context_exist; then
    echo "debug: docker context already exists"
    return
  fi
  docker context create lima-${LIMA_CONTAINER_NAME} --docker "host=unix://$HOME/.lima/${LIMA_CONTAINER_NAME}/sock/docker.sock"
  docker context use lima-${LIMA_CONTAINER_NAME}
}
# @end

# @run
install_lima
install_docker_cli
create_lima_container
limactl start "${LIMA_CONTAINER_NAME}"
create_docker_context
# @end
