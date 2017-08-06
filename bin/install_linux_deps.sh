#! /usr/bin/env bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$THIS_DIR/.."
pip install --upgrade pip
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
pip install autoenv
echo "source `which activate.sh`" >> ~/.bashrc
source ~/.bashrc
pushd .
cd "$ROOT_DIR"
pip install -r $(ROOT_DIR)/requirements.txt
popd
