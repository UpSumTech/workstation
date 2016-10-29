# workstation

This repo contains scripts to setup a developer machine in a vagrant VM or locally on a ubuntu 14.04 box

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
    Also remove the entry for the VM host from your ~/.ssh/known_hosts file

    ```shell
    vagrant up
    ```

2. Build the VM

    The password for connecting to Vagrant VM's is "vagrant" by default.
    The VM's need your github credentials to be able to pull certain repos.
    The scripts require your ssh keys for github to be present in a certain directory.

    Available VM's are
    - workstation.dev

    Setup the paths for the required ssh keys like so.
    This is valid only if you use the keys specified in those locations for your github account
    ```shell
    [ -d ~/.ssh/github ] || mkdir ~/.ssh/github/
    [ -f ~/.ssh/github/id_rsa ] || cp ~/.ssh/id_rsa ~/.ssh/github/id_rsa
    [ -f ~/.ssh/github/id_rsa.pub ] || cp ~/.ssh/id_rsa ~/.ssh/github/id_rsa.pub
    ```

    Run the bootstrap target on the Makefile to setup the VM's like so.
    The bootstrap sets up the a user called developer and copies your github ssh credentials from the host to the VM.
    Also the developer user in the VM has sudo access and it's ssh authentication is key based.
    This developer user has no password login.
    ```shell
    make bootstrap HOST_IP=<172.20.20.10> # The host ip could be localhost or the vm ip
    ```

    For provisioning the developer user in the VM or local machine
    ```shell
    make build HOST_IP=<172.20.20.10> DRY_RUN=off # The host ip could be localhost or the vm ip
    make build HOST_IP=<172.20.20.10> # This just does a dry run of your build target with ansible.
    ```
