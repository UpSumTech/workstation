# workstation

This repo contains scripts to setup a developer machine in a vagrant VM or locally on a ubuntu 16.04 box
This is an opinionated playbook for setting a fully functional development environment. It leverages some of my other projects too which i use on a daily basis.
This is what it does :

This sets up a new user account called developer on a Ubuntu machine.

1. It sets up bash with a proper bashrc and also bash-it
2. It sets up tmux and also sets up the tmux configuration tool from https://github.com/sumanmukherjee03/tmux_setup
3. It locally sets up vim in your user account instead of the system vim and also sets up the vim configuration from https://github.com/sumanmukherjee03/vim_setup
4. It sets up docker and docker-machine
5. It sets up kubectl
6. It sets up mysql with a root user. The password for this is pulled from aws kms.
7. It sets up postgres with a root user. The password for this is pulled from aws kms.
8. It sets up git with a proper git config from https://github.com/sumanmukherjee03/git-setup
9. It sets up ssh with proper keys for github. These keys need to be saved in aws kms (This needs to be configured a bit to allow different names and zones)
10. It also sets up a whole bunch of envs for development
  - ruby with rbenv
  - python with pyenv
  - golang with goenv
  - java with jenv
  - node with nvm
  - and also autoenv for project specific shell exports
11. It also sets up a whole bunch of tools for development. If you are curious have a look at ansible/roles/utils

## Getting started

### Pre-requirements

1. Virtualbox, Vagrant, ansible

    If you are on a mac, you can install virtualbox and vagrant
    Also, install ansible using pip on a mac

    ```shell
    brew cask install virtualbox vagrant
    pip install ansible
    ```

### Setting up the VM or Local machine

1. Setup the VMs if you dont already have one

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
    By default the username to be provisioned is developer unless you over ride it
    ```shell
    make build HOST_IP=<172.20.20.10> DRY_RUN=off DEBUG=on USER="<username>" GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>" # The host ip could be localhost or the vm ip
    make build HOST_IP=<172.20.20.10> DEBUG=on USER="<username>" GIT_USER="<git user name with no spaces>" GIT_EMAIL="<git user email>" # This just does a dry run of your build target with ansible.
    ```

    If you are seeing ssh connection failure after having rebuilt a vagrant box more than once,
    dont forget to remove the entry from ~/.ssh/known_hosts for the vagrant box

### Post setup steps if on a local Ubuntu box

1.  Manual interactive steps on the GUI to setup the solarized theme

    Post setup for the solarized color theme setup on ubuntu gnome term follow
    [gnome-terminal-colors-solarized]: https://github.com/Anthony25/gnome-terminal-colors-solarized
    This installs the solarized color pallete in gnome terminal. You still need to navigate to
    Terminal > Preferences > Profiles > Unnamed/<Your profile name> > Edit > colors > Built in color schemes
    and choose Solarized as the color theme.

2.  Manual interactive steps on the CLI to setup pass on Linux

    ```shell
    gpg --gen-key # This generates the key for the encryption
    gpg init <your email> # This initiates the password store
    pass ls # To list the passwords
    ```

    You can always use the help menu for more info on pass

3.  Get all the binaries for vim-go
    Open vim and :GoInstallBinaries to get all the bins required for vim-go to work
