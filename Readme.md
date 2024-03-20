# playground
All-in-one environment setup tools.

## TL;DR
```sh
curl -sSfL 'https://raw.githubusercontent.com/zaky-jp/playground/main/setup.sh' | bash
```

## How it works
```
setup.sh --> setup.zsh --> shell/configure.zsh --> ${RUNOS}/init.zsh -> ...
```
1. `setup.sh` ensure `zsh` is installed
2. `setup.zsh` clones this directory and prepare submodules
3. `shell/configure.zsh` fires necessary configurations for `zsh` to work
3. `${RUNOS}/init.zsh` is called for setup

# Concept
A mixture of *dotfiles*, *IaC*, personal utilities... that can be cloned and run across different environments: regardless of the machine types, whether it's a laptop, a server, or even insider a container.

- Be idempotent
  - Nothing should assume something is run only once, or only after.
  - Always produce desired results even `install.zsh` is run multiple times.
- Assume different architecture
  - Should produce desired results for `amd64` and `arm64`, or `macos` and `ubuntu`, and likewise.
- Fail if anything goes wrong
  - Ensure to check and fail fast

# A set of rules
## shellscript
Always use zsh;
Bash is only used to install zsh to the system.

Scripts should *always* call ```set -eu``` to ensure it fails if anything goes wrong.

Use `#!/usr/bin/env zsh` shellbang rather than `#!/bin/zsh`, as OS may not have the latest version installed to `/bin`.

## git
All commit messages should follow *conventional commits* rules. 

Refer [specification][conv_commit_specs] for further details.

[conv_commit_specs]: https://www.conventionalcommits.org/ja/v1.0.0/
