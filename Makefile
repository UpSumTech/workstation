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

TASK_FILES := $(call rfind,ansible/,**/tasks/[^.]*.yml)
FILES_TO_BE_COPIED := $(call rfind,ansible/,**/files/[^.]*.yml)

DEPS_STATEFILE = .make/done_deps

OS := $(call get_os)

INSTALL_MAC_DEPS_SCRIPT := bin/install_mac_deps.sh
INSTALL_LINUX_DEPS_SCRIPT := bin/install_linux_deps.sh
DEPS_SCRIPT = $(INSTALL_$(OS)_DEPS_SCRIPT)

MACHINE :=
VM_BOOTSTRAP_FILE := ansible/bootstrap-vm.yml
LOCAL_BOOTSTRAP_FILE := ansible/bootstrap-local.yml
BOOTSTRAP_FILE = $($(MACHINE)_BOOTSTRAP_FILE)

VM_HOSTS_FILE := ansible/vmhosts
LOCAL_HOSTS_FILE := ansible/localmachinehosts
HOSTS_FILE = $($(MACHINE)_HOSTS_FILE)

##########################################################################################
## Public targets

.DEFAULT_GOAL := build
.PHONY : deps build clean help

deps : $(DEPS_STATEFILE)

build : $(DEPS_STATEFILE) $(TASK_FILES) $(FILES_TO_BE_COPIED) $(BOOTSTRAP_FILE) $(HOSTS_FILE) ansible/main.yml
ifeq ($(OS),MAC)
	./bin/provision.sh -b VM
else
	./bin/provision.sh -b $(MACHINE)
endif

clean :
	$(AT)rm -rf .make

help :
	echo make deps # install dependancies
	echo make build MACHINE=<VM | LOCAL> # build the workstation on a vm or on local
	echo make clean # remove cache and temp dirs
	echo make help # help menu

##########################################################################################
## Plumbing

$(DEPS_STATEFILE) : $(DEPS_SCRIPT)
	mkdir -p .make
	cat $(DEPS_SCRIPT) | bash
	touch $(DEPS_STATEFILE)
