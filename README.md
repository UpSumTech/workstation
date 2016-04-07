# workstation

This repo contains scripts to setup a developer machine in a vagrant VM.

## Getting started

### Pre-requirements

1. Virtualbox, Vagrant, ansible

    If you are on a mac, you can install virtualbox and vagrant using homebrew
    Also, install ansible using pip on a mac

    ```shell
    brew cask install virtualbox vagrant
    pip install ansible
    ```

### Setting up the VM

1. Setup the VMs

    Make sure you have deleted an existing ./.vagrant directory in the project's directory

    ```shell
    vagrant up
    ```

2. Build the VM

    The password for connecting to Vagrant VM's is vagrant by default.
    The VM's need your github credentials to be able to pull certain repos.
    The scripts require your ssh keys for github to be present in a certain directory.

    Available VM's are
    - workstation.dev

    Setup the paths for the required ssh keys like so
    ```shell
    [ -d ~/.ssh/github ] || mkdir ~/.ssh/github/
    [ -f ~/.ssh/github/id_rsa ] || cp ~/.ssh/id_rsa ~/.ssh/github/id_rsa
    [ -f ~/.ssh/github/id_rsa.pub ] || cp ~/.ssh/id_rsa ~/.ssh/github/id_rsa.pub
    ```

    Run the bootstrap script to setup the VM's like so.
    The botstrap sets up the user and ssh credentials for the VM too.
    ```shell
    ./bin/provision.sh -b
    ```

    For subsequent updates of the VM avoid bootstrapping it.
    ```shell
    ./bin/provision.sh
    ```
