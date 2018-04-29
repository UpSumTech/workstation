#! /usr/bin/env bash

export KUBE_CERTS_DIR=$HOME/.kube_certs

__kube_helper_ok() {
  echo -n ""
}

__kube_helper_err() {
  echo "ERROR >> $1" >/dev/stderr
  exit 1
}

__check_kubectl() {
  command -v kubectl >/dev/null 2>&1 || __kube_helper_err "You dont have kubectl installed"
}

kube_get_namespaces() {
  __check_kubectl
  kubectl get namespace -o template --template=$'{{range .items}}{{.metadata.name}}\n{{end}}'
}

kube_set_creds() {
  local user="$1"
  __check_kubectl
  kubectl config set-credentials "$user" \
    --certificate-authority="$KUBE_CERTS_DIR/ca.pem" \
    --client-key="$KUBE_CERTS_DIR/key.pem" \
    --client-certificate="$KUBE_CERTS_DIR/cert.pem"
}

kube_set_cluster() {
  local cluster="$1"
  local server="$2"
  __check_kubectl
  kubectl config set-cluster "$cluster" \
    --server="$server" \
    --certificate-authority="$KUBE_CERTS_DIR/ca.pem"
}
