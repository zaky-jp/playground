# @define .push function
# @output append to the beginning of the $path variants
function path.push() {
  local new_path=$1
  if [[ -d $new_path ]]; then
    echo "debug: adding '$new_path' to \path"
    path=($new_path $path)
  else
    echo "debug: $new_path does not exist. skipping..."
  fi
}

function path.clean() {
  typeset -Ug path
}

function fpath.push() {
  local new_path=$1
  if [[ -d $new_path ]]; then
    echo "debug: adding '$new_path' to fpath"
    fpath=($new_path $fpath)
  else
    echo "debug: $new_path does not exist. skipping..."
  fi
}

function fpath.clean() {
  typeset -Ug fpath
}

function manpath.push() {
  local new_path=$1
  if [[ -d $new_path ]]; then
    echo "debug: adding '$new_path' to manpath"
    manpath=($new_path $manpath)
  else
    echo "debug: $new_path does not exist. skipping..."
  fi
}

function manpath.clean() {
  typeset -Ug manpath
}
# @end