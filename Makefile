##########################################################################################
## Functions

find = $(shell find '$(1)' -path '$(2)')
uname_s = $(shell uname -s)
get_os = $(if $(findstring Darwin,$(call uname_s)),MAC,LINUX)

##########################################################################################
## Variables

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

INSTALL_MAC_DEPS_SCRIPT := bin/install_mac_deps.sh
INSTALL_LINUX_DEPS_SCRIPT := bin/install_linux_deps.sh
DEPS_SCRIPT = $(INSTALL_$(OS)_DEPS_SCRIPT)

HOST_IP :=

MACHINE :=
ifeq ($(HOST_IP),'localhost')
	MACHINE = LOCAL
else
	MACHINE = VM
endif

VM_BOOTSTRAP_FILE := ansible/bootstrap-vm.yml
LOCAL_BOOTSTRAP_FILE := ansible/bootstrap-local.yml
BOOTSTRAP_FILE = $($(MACHINE)_BOOTSTRAP_FILE)

VM_HOSTS_FILE := ansible/vmhosts
LOCAL_HOSTS_FILE := ansible/localmachinehosts
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

$(BOOTSTRAP_STATEFILE) : clean $(DEPS_STATEFILE) $(BOOTSTRAP_FILE) $(HOSTS_FILE)
	$(AT)ansible-playbook -c $(CONN_TYPE) -i "$(HOSTS_FILE)" "$(BOOTSTRAP_FILE)" --ask-pass --sudo
	$(AT)touch $(BOOTSTRAP_STATEFILE)

build : bootstrap $(TASK_FILES) $(ROLES_FILES) ansible/main.yml
	$(AT)./bin/provision.py --host=$(HOST_IP) $(IGNORE_DRY_RUN)

clean :
	$(AT)[ -f "$(BOOTSTRAP_STATEFILE)" ] && rm $(BOOTSTRAP_STATEFILE); echo "Nothing to clean"

fullclean :
	$(AT)rm -rf .make

help :
	echo make deps # install dependancies
	echo make bootstrap MACHINE=<VM | LOCAL> # bootstrap the workstation on a vm or on local
	echo make build HOST_IP=<172.20.20.10> # This is a dry run to build the workstation on a host ip or on localhost
	echo make build HOST_IP=<172.20.20.10> DRY_RUN=off # This target builds the workstation on a host ip or on localhost
	echo make clean # remove cache and temp dirs
	echo make help # help menu

##########################################################################################
## Plumbing

$(DEPS_STATEFILE) : $(DEPS_SCRIPT)
	mkdir -p .make
	cat $(DEPS_SCRIPT) | bash
	touch $(DEPS_STATEFILE)
