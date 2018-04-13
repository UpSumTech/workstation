# workstation

This repo contains scripts to setup a developer machine in a vagrant VM or locally on a ubuntu 14.04 box

## Getting started

### Pre-requirements

1. Virtualbox, Vagrant, ansible

    If you are on a mac, you can install virtualbox and vagrant
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

2. Build the VM or a local machine with an ubuntu installation

    The password for connecting to Vagrant VM's is "vagrant" by default.
    The VM's need your github credentials to be able to pull certain repos.
    The scripts require your ssh keys for github to be present in a certain directory.

    Available VM's are
    - workstation.dev

    It could also be a developer notebook with an ubuntu installation in which case host would be localhost.

    Run the bootstrap target on the Makefile to setup the VM's like so.
    The bootstrap sets up the a user called developer and copies your github ssh credentials from the host to the VM.
    Also the developer user in the VM has sudo access and it's ssh authentication is key based.

    This developer user has no password login.
    ```shell
    make bootstrap DRY_RUN=off HOST_IP=<172.20.20.10> DEBUG=on GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>" # The host ip could be localhost or the vm ip
    ```

    For provisioning a Ubuntu desktop that has a user which needs a password for sudo'ing
    ```shell
    make bootstrap HOST_IP=localhost DRY_RUN=off SUDO_PASSWD=<sudo password> DEBUG=on GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>"
    ```

    For provisioning the developer user in the VM or local machine
    ```shell
    make build HOST_IP=<172.20.20.10> DRY_RUN=off DEBUG=on GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>" # The host ip could be localhost or the vm ip
    make build HOST_IP=<172.20.20.10> DEBUG=on GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>" # This just does a dry run of your build target with ansible.
    ```

    Post setup for the solarized color theme setup on ubuntu gnome term follow
    [gnome-terminal-colors-solarized]: https://github.com/Anthony25/gnome-terminal-colors-solarized
    This installs the solarized color pallete in gnome terminal. You still need to navigate to
    Terminal > Preferences > Profiles > Unnamed/<Your profile name> > Edit > colors > Built in color schemes
    and choose Solarized as the color theme.
