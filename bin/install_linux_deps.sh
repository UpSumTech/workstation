#! /usr/bin/env bash

curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
pip install autoenv
echo "source `which activate.sh`" >> ~/.bashrc
source ~/.bashrc
pip install -r requirements.txt
