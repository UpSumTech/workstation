#! /usr/bin/env bash

install_libs() {
  sudo brew install -y \
    libtool \
    openssl \
    pyenv \
    pyenv-virtualenv \
    autoenv
}

install_pyenv() {
  cat $HOME/.bash_profile | grep -i 'pyenv' || { echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.bash_profile \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bash_profile \
    && echo 'command -v pyenv 1>/dev/null 2>&1 && eval "$(pyenv init -)"' >> $HOME/.bash_profile; }
}

install_pyenv_virtualenv() {
  cat $HOME/.bash_profile | grep -i 'virtualenv-init' || echo 'command -v pyenv 1>/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"' >> $HOME/.bash_profile
}

install_autoenv() {
  cat $HOME/.bash_profile | grep -i 'autoenv' || echo '. $HOME/.autoenv/activate.sh' >> $HOME/.bash_profile
}

main() {
  install_libs
  install_pyenv
  install_pyenv_virtualenv
  install_autoenv
  pip install --upgrade pip
  . $HOME/.bashrc
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
