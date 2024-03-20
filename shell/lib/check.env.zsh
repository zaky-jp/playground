# @define check functions
function check_file_exist() {
  local file=$1
  [[ -e $file || -h $file ]] # macos does not follow symlink with -e
  return $?
}

function check_dir_exist() {
	local dir=$1
	[[ -d $dir ]]
	return $?
}

function check_formula_installed_with_brew() {
	if ! (( ${+formulae} )); then
		source "${brew_cache[formulae]}"
	fi
  local package=$1

  (( ${formulae[(I)$package]} ))
  return $?
}

function check_cask_installed_with_brew() {
	if ! (( ${+casks} )); then
		source "${brew_cache[casks]}"
	fi
  local package=$1

  (( ${casks[(I)$package]} ))
  return $?
}