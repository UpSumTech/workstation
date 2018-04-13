##########################################################################################
## Functions

rfind = $(shell find '$(1)' -path '$(2)')
uname_s = $(shell uname -s)
get_os = $(if $(findstring Darwin,$(call uname_s)),MAC,LINUX)
get_ip_type = $(if $(shell echo $(1) | grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)'),'private','public')

##########################################################################################
## Variables

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
GIT_USER :=
GIT_EMAIL :=

DEBUG := off
AT_off := @
AT_on :=
AT = $(AT_$(DEBUG))

DRY_RUN := on
IS_DRY_RUN_on :=
IS_DRY_RUN_off := --ignore-dry-run
IGNORE_DRY_RUN = $(IS_DRY_RUN_$(DRY_RUN))

TASK_FILES := $(call rfind,ansible/,**/tasks/[^.]*.yml)
ROLES_FILES := $(call rfind,ansible/,**/files/[^.]*.yml)

DEPS_STATEFILE = .make/done_deps
BOOTSTRAP_STATEFILE = .make/done_bootstrap

OS := $(call get_os)

HOST_IP :=
MACHINE :=
PLAYBOOK_TYPE :=
BASH_LOGIN_SOURCE :=
INSTALL_DEPS_FILE :=
ifeq ($(HOST_IP),localhost)
	MACHINE = LOCAL
	LOCAL_HOSTS_FILE := ansible/local-hosts
ifeq ($(OS),MAC)
	PLAYBOOK_TYPE = MAC_LOCAL
	BASH_LOGIN_SOURCE = $$HOME/.bash_profile
	INSTALL_DEPS_FILE = bin/mac_deps.sh
else
	PLAYBOOK_TYPE = LINUX_LOCAL
	BASH_LOGIN_SOURCE = $$HOME/.bashrc
	INSTALL_DEPS_FILE = bin/linux_deps.sh
endif
else
	MACHINE = VM
ifeq ($(OS),MAC)
	VM_HOSTS_FILE := ansible/local-vm-hosts
	PLAYBOOK_TYPE = MAC_VM
	BASH_LOGIN_SOURCE = $$HOME/.bashrc
	INSTALL_DEPS_FILE = bin/mac_deps.sh
else
	VM_HOSTS_FILE :=
	PLAYBOOK_TYPE = CLOUD_VM
	BASH_LOGIN_SOURCE = $$HOME/.bashrc
	INSTALL_DEPS_FILE = bin/linux_deps.sh
  $(error "Only supporting mac os hosts for VMs at this point. Cloud VM hosts will be added afterwards")
endif
endif

BOOTSTRAP_FILE = ansible/bootstrap.yml
PLAYBOOK_FILE := ansible/main.yml
HOSTS_FILE = $($(MACHINE)_HOSTS_FILE)

VM_CONN_TYPE := paramiko
LOCAL_CONN_TYPE := local
CONN_TYPE = $($(MACHINE)_CONN_TYPE)

##########################################################################################
## Public targets

.DEFAULT_GOAL := bootstrap
.PHONY : deps bootstrap build clean fullclean help

deps : $(DEPS_STATEFILE)

bootstrap : $(BOOTSTRAP_STATEFILE)

$(BOOTSTRAP_STATEFILE) : $(DEPS_STATEFILE) $(BOOTSTRAP_FILE) $(HOSTS_FILE)
ifdef SUDO_PASSWD
	$(AT)ansible-playbook -i $(HOSTS_FILE) --user=$(shell whoami) --extra-vars "ansible_sudo_pass=$(SUDO_PASSWD)" $(BOOTSTRAP_FILE)
else
	$(AT)ansible-playbook -i $(HOSTS_FILE) $(BOOTSTRAP_FILE)
endif
	$(AT)touch $(BOOTSTRAP_STATEFILE)

build : bootstrap $(TASK_FILES) $(ROLES_FILES) $(PLAYBOOK_FILE)
ifdef SUDO_PASSWD
	$(AT)PLAYBOOK_TYPE=$(PLAYBOOK_TYPE) GIT_USER=$(GIT_USER) GIT_EMAIL=$(GIT_EMAIL) SUDO_PASSWD=$(SUDO_PASSWD) ./bin/provision.py developer --host=$(HOST_IP) --playbook=$(PLAYBOOK_FILE) $(IGNORE_DRY_RUN)
else
  $(AT)PLAYBOOK_TYPE=$(PLAYBOOK_TYPE) GIT_USER=$(GIT_USER) GIT_EMAIL=$(GIT_EMAIL) ./bin/provision.py developer --host=$(HOST_IP) --playbook=$(PLAYBOOK_FILE) $(IGNORE_DRY_RUN)
endif

clean :
	$(AT)[ -f "$(BOOTSTRAP_STATEFILE)" ] && rm $(BOOTSTRAP_STATEFILE); echo "Nothing to clean"

fullclean :
	$(AT)rm -rf .make

help :
	@echo make deps # install dependancies
	@echo make bootstrap MACHINE=VM # bootstrap the workstation on a vm or on local
	@echo make build HOST_IP=172.20.20.10 # This is a dry run to build the workstation on a host ip or on localhost
	@echo make build HOST_IP=172.20.20.10 DRY_RUN=off # This target builds the workstation on a host ip or on localhost
	@echo make clean # remove cache and temp dirs
	@echo make help # help menu

##########################################################################################
## Plumbing

$(DEPS_STATEFILE) : requirements.txt
	mkdir -p $(ROOT_DIR)/.make
	$(AT)./$(INSTALL_DEPS_FILE)
	cd $(ROOT_DIR)
	pip install -r requirements.txt
	touch $(DEPS_STATEFILE)
