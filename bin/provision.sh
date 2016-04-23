#!/bin/bash
# Summary: Bootstrapping and provisioning the workstation

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$THIS_DIR/../ansible"

main() {
  if [[ "$2" =~ "VM" ]]; then
    if [[ "$1" =~ "-b" ]]; then
      ansible-playbook -c paramiko \
        -i "$ANSIBLE_DIR/vmhosts" \
        "$ANSIBLE_DIR/bootstrap-vm.yml" \
        --ask-pass \
        --sudo
    fi

    ansible-playbook -c paramiko \
      -i "$ANSIBLE_DIR/vmhosts" \
      "$ANSIBLE_DIR/main.yml"

  elif [[ "$2" =~ "LOCAL" ]]; then
    if [[ "$1" =~ "-b" ]]; then
      ansible-playbook --connection=local \
        -i "$ANSIBLE_DIR/localmachinehosts" \
        "$ANSIBLE_DIR/bootstrap-local.yml" \
        --ask-pass \
        --sudo
    fi

    ansible-playbook -c paramiko \
      -i "$ANSIBLE_DIR/localmachinehosts" \
      "$ANSIBLE_DIR/main.yml"
  else
    echo "The options are not valid"
    exit 1
  fi
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
