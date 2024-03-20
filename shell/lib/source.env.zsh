# @override source command
function source() {
  file_path=$1
  echo "debug: sourcing from '${file_path}'" 
  builtin source "$file_path"
}
# @end