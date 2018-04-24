#! /usr/bin/env bash

[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/tmp" ]] && export TMPDIR="$HOME/tmp"
[[ -d "$HOME/.rbenv" ]] && export PATH="$HOME/.rbenv/bin:$PATH"
command -v rbenv 1>/dev/null 2>&1 && eval "$(rbenv init -)"
[[ -d "$HOME/.pyenv" ]] && export PYENV_ROOT="$HOME/.pyenv" && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv 1>/dev/null 2>&1 && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"
[[ -d "$HOME/.goenv" ]] && export GOENV_ROOT="$HOME/.goenv" && export PATH="$GOENV_ROOT/bin:$PATH"
command -v goenv 1>/dev/null 2>&1 && eval "$(goenv init -)"
[[ -d "$HOME/go" ]] && export GOPATH="$HOME/go" && export PATH="$GOPATH/bin:$PATH"
[[ -d "$HOME/.nvm" ]] && export NVM_DIR="$HOME/.nvm"
[[ -f "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -d "$HOME/.autoenv" ]] && . "$HOME/.autoenv/activate.sh"
[[ -d "$HOME/.jenv" ]] && export PATH="$HOME/.jenv/bin:$PATH"
command -v jenv 1>/dev/null 2>&1 && eval "$(jenv init -)"
[[ -x "$HOME/bin/vim" ]] && export EDITOR="$HOME/bin/vim"
command -v kubectl 1>/dev/null 2>&1 && . <(kubectl completion bash)
