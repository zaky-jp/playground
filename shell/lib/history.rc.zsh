# @define environment variables
export HISTFILE="${XDG_DATA_HOME}/zsh/histfile"
export HISTSIZE=1001
export SAVEHIST=1000
# @end

# @define check functions
# @output status code
function check_histfile_writable() {
  [[ -w "${HISTFILE}" ]]
  return $?
}
# @end

# @define perform functions
# @output file changes
function create_histfile() {
  (( ${+HISTFILE} )) || { echo 'error: HISTFILE is not set.'; return 1; }
  if [[ -d "${HISTFILE:h}" ]]; then
    mkdir -p "${HISTFILE:h}" 
  fi
  touch ${HISTFILE}
}
# @end

# @define configure functions
# @output zsh options changed
function set_history_write_options() {
  # what to write
  setopt append_history
  setopt extended_history
  setopt inc_append_history_time
  setopt hist_ignore_dups
  setopt hist_ignore_space
  setopt hist_reduce_blanks
  setopt hist_no_store # supress storing history command itself
  # time config
  setopt hist_fcntl_lock # use os-native filelock
  # rotation
  setopt hist_expire_dups_first # need $histsize > $savehist
}

function set_history_read_options() {
  setopt hist_lex_words # shell-like whitespace handling
  setopt hist_verify # safe paste; do not execute the command directly
  setopt hist_find_no_dups
}

# @run
if ! check_histfile_writable; then
  create_histfile
fi
set_history_write_options
set_history_read_options
# @end
