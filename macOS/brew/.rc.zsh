# @define filer functions
function mkdir_config_home {
	if check_dir_exist "${brew_config[shellenv]:a:h}"; then
		echo "warning: ${brew_config[shellenv]:a:h} already exist."
		return 0
	fi
	mkdir -p "${brew_config[shellenv]:a:h}"
}

function mkdir_cache_home {
	if check_dir_exist "${brew_cache[formulae]:a:h}"; then
		echo "warning: ${brew_cache[formulae]:a:h} already exist."
		return 0
	fi
	mkdir -p "${brew_cache[formulae]:a:h}"
}
# @end

# @define generate functions
function generate_shellenv() {
	brew shellenv zsh | tee "${brew_config[shellenv]}" >/dev/null
}

function generate_formulae_cache() {
	builtin echo "typeset -ga formulae" | tee "${brew_cache[formulae]}" >/dev/null
	builtin echo "formulae=(${(f)$(brew list --formulae --full-name -1)})" | tee -a "${brew_cache[formulae]}" >/dev/null
}

function generate_cask_cache() {
	builtin echo "typeset -ga casks" | tee "${brew_cache[casks]}" >/dev/null
	builtin echo "casks=(${(f)$(brew list --cask --full-name -1)})" | tee -a "${brew_cache[casks]}" >/dev/null
}
# @end