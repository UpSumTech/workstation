#!/bin/bash
# Summary: Bootstrapping and provisioning the workstation

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$THIS_DIR/../ansible"

main() {
  export ANSIBLE_SCP_IF_SSH=y

  if [[ "$1" =~ "-b" ]]; then
    ansible-playbook -c paramiko \
      -i "$ANSIBLE_DIR/hosts" \
      "$ANSIBLE_DIR/bootstrap.yml" \
      --ask-pass \
      --sudo
  fi

  ansible-playbook -i "$ANSIBLE_DIR/hosts" \
    "$ANSIBLE_DIR/main.yml"
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
