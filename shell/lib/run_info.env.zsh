# @define RUNOS variable
if ! (( ${+RUNOS} )); then
  case $OSTYPE in
    "linux-gnu")
      export RUNOS="${(L)$(lsb_release --id --short)}" # convert to lowercase
      ;;
    "darwin"*)
      export RUNOS="macos"
      ;;
    *)
      RUNOS="${OSTYPE}"
      ;;
  esac
fi
# @end

# @define RUNARCH variable
if ! (( ${+RUNARCH} )); then
  local arch=$(uname -m)
  case $arch in
    "x86_64")
      export RUNARCH="amd64"
      ;;
    *)
      export RUNARCH="${arch}"
      ;;
  esac
  unset arch
fi
# @end
