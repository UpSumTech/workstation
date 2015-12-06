#!/bin/bash
# Summary: Bootstrapping and provisioning the workstation

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$THIS_DIR/../ansible"

ansible-playbook -c paramiko \
  -i "$ANSIBLE_DIR/hosts" \
  "$ANSIBLE_DIR/bootstrap.yml" \
  --ask-pass \
  --sudo

ansible-playbook -i "$ANSIBLE_DIR/hosts" \
  "$ANSIBLE_DIR/main.yml"
