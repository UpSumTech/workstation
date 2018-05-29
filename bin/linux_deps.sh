#! /usr/bin/env bash

install_libs() {
  sudo apt-get install -y \
    python-pip \
    build-essential \
    libtool \
    openssl \
    libssl-dev \
    libffi-dev \
    python-dev \
    python3-dev \
    openssh-server
}

install_pyenv() {
  [[ -d $HOME/.pyenv ]] || git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
  cat $HOME/.bashrc | grep -i 'pyenv' || { echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc \
    && echo 'command -v pyenv 1>/dev/null 2>&1 && eval "$(pyenv init -)"' >> $HOME/.bashrc; }
  echo "pyenv installed"
}

install_pyenv_virtualenv() {
  [[ -d $HOME/.pyenv/plugins/pyenv-virtualenv ]] || git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
  cat $HOME/.bashrc | grep -i 'virtualenv' || { echo 'command -v pyenv 1>/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc; }
  echo "pyenv virtualenv installed"
}

install_autoenv() {
  [[ -d $HOME/.autoenv ]] || git clone https://github.com/kennethreitz/autoenv.git $HOME/.autoenv
  cat $HOME/.bashrc | grep -i 'autoenv' || { echo '. $HOME/.autoenv/activate.sh' >> $HOME/.bashrc; }
  echo "autoenv installed"
}

setup_ssh_keys_and_tokens() {
  [[ -d $HOME/.ssh ]] || { mkdir -p $HOME/.ssh; chmod 700 $HOME/.ssh; }
  if [[ ! -f $HOME/.ssh/id_rsa && ! -f $HOME/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -N "" -b 4096 -C "ssh private key" -f $HOME/.ssh/id_rsa
    chmod 600 $HOME/.ssh/id_rsa
    chmod 600 $HOME/.ssh/id_rsa.pub
  fi
  touch $HOME/.ssh/authorized_keys
  cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
  chmod 600 $HOME/.ssh/authorized_keys
  ssh-keyscan -H localhost >> $HOME/.ssh/known_hosts
  echo "updated ssh"
}

main() {
  install_libs
  install_pyenv
  install_pyenv_virtualenv
  install_autoenv
  pip install --upgrade pip
  setup_ssh_keys_and_tokens
  . $HOME/.bashrc
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
