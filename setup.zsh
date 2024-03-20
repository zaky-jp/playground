#!/usr/bin/env zsh
set -eu

# @define environment variables
export PLAYGROUND_REPO="zaky-jp/playground"
export PLAYGROUND_DIR="${HOME}/playground"
typeset -A submodule_wanted_files
submodule_wanted_files[alacritty/upstream]='extra/alacritty.info'
submodule_wanted_files[neovim/jetpack]='plugin/jetpack.vim'
# @end

# @override echo to output to stderr
# @output stderr
if ! (( ${+functions[echo]} )); then
  function echo() {
    builtin echo "$@" >&2
  }
fi
# @end

# @define check functions
# @output status code
function check_clone_status() {
  [[ -d "${PLAYGROUND_DIR}/.git" ]]
  return $?
}

function check_sparsecheckout_status() {
  local submodule_name=$1
  [[ $(git -C "${PLAYGROUND_DIR}/${submodule_name}" config --get core.sparsecheckout) == 'true' ]]
  return $?
}
# @end

# @define perform functions
# @output file changes
function clone_playground_repo() {
  git clone --recurse-submodules --shallow-submodules "https://github.com/${PLAYGROUND_REPO}.git" "${PLAYGROUND_DIR}"
}

function apply_sparse_checkout() {
  local submodule_name=$1
  local target_files=$2
  git -C "${PLAYGROUND_DIR}/${submodule_name}" config core.sparsecheckout true
  builtin echo "${target_files}" | tee "${PLAYGROUND_DIR}/.git/modules/${submodule_name}/info/sparse-checkout" >/dev/null
  git -C "${PLAYGROUND_DIR}/${submodule_name}" read-tree -mu HEAD 
}

function fetch_playground_repo() {
  git -C "${PLAYGROUND_DIR}" fetch --all --recurse-submodules
}

function update_submodules() {
  git -C "${PLAYGROUND_DIR}" submodule update --init --recursive --recommend-shallow --depth 1
}

# @run
# normally git should be present in the system but ensure 
if ! (( ${+commands[git]} )); then
  echo 'error: git not present in your system. aborting...'
  exit 1
fi

echo "info: cloning ${PLAYGROUND_REPO} to ${PLAYGROUND_DIR}..."
if check_clone_status; then
  echo "warning: ${PLAYGROUND_DIR} already exists and managed by git. skipping..."
else
  clone_playground_repo
fi

echo "info: fetching all submodules"
fetch_playground_repo
echo "info: updating all submodules"
update_submodules

for submodule in ${(k)submodule_wanted_files}; do
  if ! check_sparsecheckout_status "${submodule}"; then
    echo "info: applying sparsecheckout for ${submodule}..."
    apply_sparse_checkout "${submodule}" "${submodule_wanted_files[${submodule}]}"
  else
    echo "debug: sparsecheckout already applied for ${submodule}"
  fi
done


zsh "${PLAYGROUND_DIR}/shell/configure.zsh"
