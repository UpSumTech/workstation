#! /usr/bin/env bash

############################## PRIVATE HELPER FNS #############################

__ok() {
  echo -n ""
}

__err() {
  echo "ERROR >> $1" >/dev/stderr
}

__check_kubectl() {
  command -v kubectl >/dev/null 2>&1 || __err "You dont have kubectl installed"
}

__chdir_and_exec() {
  local result
  local fn="$1"
  shift 1
  pushd .
  result=$(eval "$(declare -F "$fn")" "$@")
  popd
  echo "$result"
}

start_ssh_agent_and_add_key() {
  eval `ssh-agent -s`
  ssh-add -K "$1"
  __ok
}

mv_2_go_project_root() {
  while [[ ! $(find . -maxdepth 1 -type d | grep '.git') =~ './.git' && ! $(basename $(cd $PWD/../.. && pwd)) =~ (github.com|golang.org|google.golang.org|gopkg.in) ]]; do
    cd ..
  done
}

install_go_deps_for_project() {
  pushd .
  mv_2_go_project_root
  if [[ ! -f "$PWD/Gopkg.toml" && ! -f "$PWD/Gopkg.lock" ]]; then
    go get -u $(find . -maxdepth 1 ! -path . ! -path '*/\.*' -type d | grep -v vendor | xargs -n 1 -I % echo %/...)
  else
    dep ensure -vendor-only
  fi
  popd
  __ok
}

build_static_go_bin() {
  pushd .
  mv_2_go_project_root

  local arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
  local osname="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local archname

  case "$arch" in
    x86_64)
      archname='amd64'
      ;;
    i386)
      archname='386'
      ;;
    *)
      __err "ERROR >> Arch not supported for go build process"
      ;;
  esac
  echo "Building static binary for $osname/$archname"
  CGO_ENABLED=0 gox -osarch="$osname/$archname" -rebuild -tags='netgo' -ldflags='-w -extldflags "-static"'
  popd
  __ok
}

start_docker_machine() {
  if uname -s | grep -i 'darwin'; then
    (docker-machine ls | awk '{if(NR>1) print $1,$3,$4,$5}' | grep -i '^default virtualbox' 2>&1 >/dev/null \
      || docker-machine create --driver virtualbox --virtualbox-memory "2048" --virtualbox-disk-size "40000" default) &
    eval "$(docker-machine env default)"
    (env | grep DOCKER | grep DOCKER_HOST | cut -d '=' -f2 | sed -e 's#tcp://##g;s#:# #g' | xargs nc -v \
      || (docker-machine stop default 2>&1 >/dev/null; eval "$(docker-machine env -u)"; docker-machine start default; eval "$(docker-machine env default)")) &
    wait
    eval "$(docker-machine env default)"
  else
    echo "You are on linux. You dont need docker machine. Defaulting to docker native."
  fi
  __ok
}

stop_docker_machine() {
  if uname -s | grep -i 'darwin'; then
    (docker-machine status default | grep -i "running" && (docker-machine stop default)) &
    wait
    eval "$(docker-machine env -u)"
  else
    echo "You are on linux. You probably never started docker machine. Defaulting to docker native."
  fi
  __ok
}

is_docker_machine_running() {
  if uname -s | grep -i 'darwin'; then
    docker-machine status default | grep -i "running" >/dev/null 2>&1
  else
    __ok
  fi
}

is_docker_machine_not_running() {
  if uname -s | grep -i 'darwin'; then
    !docker-machine status default | grep -i "running" >/dev/null 2>&1
  else
    __ok
  fi
}

switch_to_docker_machine() {
  stop_minikube
  stop_minishift
  start_docker_machine
  __ok
}

start_minikube() {
  (minikube status | grep -i "running" || (minikube start)) &
  wait
  eval "$(minikube docker-env)"
  __ok
}

stop_minikube() {
  (minikube status | grep -i "running" && (minikube stop)) &
  wait
  unset ${!DOCKER_*}
  __ok
}

is_minikube_running() {
  minikube status | grep -i "running" >/dev/null 2>&1
}

switch_to_minikube() {
  stop_docker_machine
  stop_minishift
  start_minikube
  __ok
}

start_minishift() {
  (minishift status | grep -i "running" || (minishift start --vm-driver virtualbox)) &
  wait
  eval "$(minishift docker-env)"
  command -v oc >/dev/null 2>&1 && eval "$(minishift oc-env)"
  __ok
}

stop_minishift() {
  (minishift status | grep -i "running" && (minishift stop)) &
  wait
  unset ${!DOCKER_*}
  __ok
}

is_minishift_running() {
  minishift status | grep -i "running" >/dev/null 2>&1
}

switch_to_minishift() {
  stop_docker_machine
  stop_minikube
  start_minishift
  __ok
}

start_default_docker_env() {
  stop_docker_machine
  stop_minikube
  stop_minishift
  start_docker_machine
  echo "$1"
  __ok
}

load_docker_env() {
  case "$1" in
    minikube)
      switch_to_minikube
      ;;
    minishift)
      switch_to_minishift
      ;;
    docker-machine)
      switch_to_docker_machine
      ;;
    *)
      if [[ is_docker_machine_not_running && !is_minikube_running && !is_minishift_running ]]; then
        start_default_docker_env "Neither minishift, minikube or docker machine were running. So defaulting."
      fi

      if [[ is_docker_machine_running && !is_minikube_running && !is_minishift_running ]]; then
        eval "$(docker-machine env default)"
      fi

      if [[ is_docker_machine_not_running && is_minikube_running && !is_minishift_running ]]; then
        eval "$(minikube docker-env)"
      fi

      if [[ is_docker_machine_not_running && !is_minikube_running && is_minishift_running ]]; then
        eval "$(minishift docker-env)"
        eval "$(minishift oc-env)"
      fi

      if [[ is_docker_machine_running && is_minikube_running && !is_minishift_running ]]; then
        start_default_docker_env "Both minikube and docker-machine are running. Stopping both of them and defaulting."
      fi

      if [[ is_docker_machine_running && !is_minikube_running && is_minishift_running ]]; then
        start_default_docker_env "Both minishift and docker-machine are running. Stopping both of them and defaulting."
      fi

      if [[ is_docker_machine_not_running && is_minikube_running && is_minishift_running ]]; then
        start_default_docker_env "Both minishift and minikube are running. Stopping both of them and defaulting."
      fi

      if [[ is_docker_machine_running && is_minikube_running && is_minishift_running ]]; then
        start_default_docker_env "All of minikube, minishift and docker-machine are running. Stopping all of them and defaulting."
      fi
      ;;
  esac
  __ok
}

login_dockerhub() {
  [[ ! -z "$DOCKERHUB_USERNAME" && ! -z "$DOCKERHUB_PASSWORD" ]] \
    || __err "dockerhub creds have not been exported to the shell"
  docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_PASSWORD"
  __ok
}

rm_intermediate_docker_images() {
  docker images | grep '<none>' | awk '{print $3}' | xargs -n 1 -I % docker rmi -f %
  __ok
}

rm_stopped_docker_containers() {
  docker ps --filter status=exited --filter status=dead --format="{{ .ID }} {{ .Names }}" \
    | awk '{print $1}' \
    | xargs -n 1 -I % docker rm %
  __ok
}

stop_docker_containers() {
  docker ps --filter status=running --filter status=restarting --filter status=removing --filter status=created --format="{{ .ID }} {{ .Names }}" \
    | awk '{print $1}' \
    | xargs -n 1 -I % docker stop %
  __ok
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
  __ok
}

kube_set_cluster() {
  local cluster="$1"
  local server="$2"
  __check_kubectl
  kubectl config set-cluster "$cluster" \
    --server="$server" \
    --certificate-authority="$KUBE_CERTS_DIR/ca.pem"
  __ok
}

kube_get_master_pods() {
  __check_kubectl
  kubectl -n kube-system get pods
}

kube_get_clusters() {
  __check_kubectl
  kubectl config get-clusters
}

ssh_port_forward() {
  local local_port="$1"
  local remote_server="$2"
  local remote_port="$3"
  if [[ ! -z "$JUMP_HOST" ]]; then
    ssh -o ExitOnForwardFailure=yes -N -L $local_port:$remote_server:$remote_port $JUMP_HOST
  else
    ssh -o ExitOnForwardFailure=yes -N -L $local_port:$remote_server:$remote_port
  fi
  __ok
}

start_mysql() {
  ps -ef | grep mysql[d] \
    || mysql.server start
  __ok
}

stop_mysql() {
  ps -ef | grep mysql[d] \
    || mysql.server stop
  __ok
}

start_psql() {
  [[ ! -z $PGDATA ]] || export PGDATA="$HOME/var/data/postgres"
  local pg_log_dir="$HOME/var/log/postgres"
  ps -ef | grep postgre[s] \
    || pg_ctl -D "$PGDATA" -l "$pg_log_dir/server.log" start
  __ok
}

stop_psql() {
  local pg_log_dir="$HOME/var/log/postgres"
  ps -ef | grep postgre[s] \
    && pg_ctl -D "$PGDATA" -l "$pg_log_dir/server.log" stop
  __ok
}

get_ip_info() {
  curl http://api.db-ip.com/v2/free/$1
  echo; nslookup $1 | grep 'name ='
}

open_fzf_finder() {
  command -v fzf \
    || __err "You dont have fzf installed"
  fzf --preview-window 'down:30' --preview '[[ $(file --mime {}) =~ binary ]] &&
    echo {} is a binary file ||
    (highlight -O ansi -l {} ||
    coderay {} ||
    rougify {} ||
    cat {}) 2> /dev/null | head -500'
}

sync_history() {
  local current_time=$(date +%s)
  if [[ -z $HISTLASTSYNCED \
    || $(( $current_time - $HISTLASTSYNCED)) -gt 120 ]]; then
    builtin history -a
    local hist_file
    if [[ ! -z "$TMUX" && ! -z "$PROJECT_ROOT_DIR" && $PROJECT_ROOT_DIR =~ $PWD ]]; then
      local hist_dir="${HOME}/.bash_history.d${PWD}"
      [[ ! -d "$hist_dir" ]] && mkdir -p "$hist_dir"
      hist_file="${hist_dir}/${USER}_bash_history.txt"
      if [[ ! -f "$hist_file" || ! -s "$hist_file" ]]; then
        touch "$hist_file"
        builtin history | awk '{$1="";print substr($0,2)}' >> "$hist_file"
        [[ -f $HOME/.bash_history ]] && cat $HOME/.bash_history >> "$hist_file"
        cat "$hist_file" | sort -u | sponge "$hist_file"
      fi
    else
      hist_file="$HOME/.bash_history"
    fi
    export HISTFILE="$hist_file"
    builtin history -c
    builtin history -r
    export HISTLASTSYNCED=$(date +%s)
  fi
  __ok
}

activate_history_sync() {
  if [[ ! "sync_history" =~ $PROMPT_COMMAND ]]; then
    export PROMPT_COMMAND="sync_history;$PROMPT_COMMAND"
  fi
  __ok
}
