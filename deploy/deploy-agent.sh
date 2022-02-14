#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

DEVICE_WORKER_IMAGE=quay.io/pdettori/flotta-device-worker
DEVICE_WORKER_EXEC=/device-worker
YGGD_IMAGE=quay.io/pdettori/yggdrasil
YGGD_EXEC=/yggd

###############################################################################################
#               Functions
###############################################################################################

set_home() {
  echo ${PROJECT_HOME} | grep flotta-device-worker > /dev/null
  if [ "$?" -ne 0 ]; then 
    echo "not running in context"
    YGGD_HOME=${HOME}/.yggd
    PROJECT_HOME=${HOME}
    IN_CTX=false
  else  
    echo "running in context"
    YGGD_HOME=${PROJECT_HOME}/.yggd
  fi  
}

create_node_exporter_service() {
cat <<EOF > /tmp/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
sudo cp /tmp/node_exporter.service /etc/systemd/system/node_exporter.service
}

install_missing_deps() {
  podman --help &> /dev/null
  if [ "$?" -ne 0 ]; then
    echo "podman not installed, trying to install"
    distro=$(cat /etc/*-release | grep '^NAME' | awk '{split($0,a,"="); print a[2]'})
    case $distro in
      Fedora)
        echo "Installing podman on Fedora..."
        sudo dnf install -y podman
      ;;
      *)
        echo "cannot find podman for distro $distro - please install manually podman"
        exit -1
      ;;
    esac
  fi

  openssl help &> /dev/null
  if [ "$?" -ne 0 ]; then
    echo "openssl not installed, trying to install"
    distro=$(cat /etc/*-release | grep '^NAME' | awk '{split($0,a,"="); print a[2]'})
    case $distro in
      Fedora)
        echo "Installing openssl on Fedora..."
        sudo dnf install -y openssl
      ;;
      *)
        echo "cannot find openssl for distro $distro - please install manually openssl"
        exit -1
      ;;
    esac
  fi

  node_exporter --help &> /dev/null
  if [ "$?" -ne 0 ]; then
    echo "node_exporter not installed, trying to install"
    curl -LO --output-dir /tmp  https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
    tar -xvf /tmp/node_exporter-0.18.1.linux-amd64.tar.gz -C /tmp
    sudo mv /tmp/node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
    sudo restorecon -rv /usr/local/bin/node_exporter
    sudo useradd -rs /bin/false node_exporter
    create_node_exporter_service
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter.service
    sudo systemctl start node_exporter.service
  fi  


}

enable_podman() {
  systemctl is-active --quiet podman.socket &> /dev/null
  if [ "$?" -ne 0 ]; then
  sudo systemctl --now enable podman.socket
  sudo loginctl enable-linger root
  fi
}

create_dirs() {
  sudo mkdir -p /usr/local/libexec/yggdrasil
  sudo mkdir -p /etc/pki/consumer
  mkdir -p ${YGGD_HOME}
}

create_certs() {
  if [ ! -f /etc/pki/consumer/cert.pem ] || [ ! -f /etc/pki/consumer/key.pem ]; then
    sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 \
    -nodes -out /etc/pki/consumer/cert.pem -keyout /etc/pki/consumer/key.pem \
    -subj "/C=US/ST=NY/L=Yorktown/O=Acme LLC/OU=devops/CN=*.acme.net"
  fi  
}

copy_agent() {
  sudo systemctl stop yggd.service &> /dev/null
  sudo cp ${YGGD_HOME}/bin/yggd /usr/local/bin/yggd
  sudo cp ${YGGD_HOME}/bin/device-worker /usr/local/libexec/yggdrasil/device-worker
}

create_yggd_service() {
HTTP_SERVER=$1
cat <<EOF > /tmp/yggd.service
[Unit]
Description=yggd
After=network.target

[Service]
Restart=on-failure
Type=simple
ExecStart=/usr/local/bin/yggd --log-level trace --transport http --cert-file /etc/pki/consumer/cert.pem --key-file /etc/pki/consumer/key.pem --client-id-source machine-id --http-server $HTTP_SERVER 

[Install]
WantedBy=multi-user.target
EOF
sudo cp /tmp/yggd.service /etc/systemd/system/yggd.service
}

extract_exec() {
  image=$1
  sourcePath=$2
  mkdir -p ${YGGD_HOME}/bin
  containerId=$(podman create $image)  
  podman cp ${containerId}:${sourcePath} ${YGGD_HOME}/bin/${sourcePath}
  podman rm ${containerId}
}

###########################################################################################
#                   Main   
###########################################################################################
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 join --hub-apiserver <hub API server URL>"
    echo "  On macOS you may only run as remote ssh to a linux machine, setting the env var SSH_CMD"
    echo "  for example, 'export SSH_CMD=\"podman machine ssh\"'"
    exit
fi

if [ "$1" != "join" ]; then
    echo "join is the only supported command"
    exit
fi

# handle macOS remote to linux
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "running on macOS"
  if [ "$SSH_CMD" == "" ]; then
    echo "Env var SSH_CMD must be set"
    exit -1
  fi
  $SSH_CMD 'bash -s' < ${SCRIPT_HOME}/deploy-agent.sh "$@"
  exit 0
fi

# handle linux remote to linux
if [ "$SSH_CMD" != "" ]; then
  $SSH_CMD 'bash -s' < ${SCRIPT_HOME}/deploy-agent.sh "$@"
  exit 0
fi

ARGS=$(getopt -a --options a: --long "hub-apiserver:" -- "$@")
eval set -- "$ARGS"

while true; do
  case "$1" in
    -a|--hub-apiserver)
      apiserver="$2"
      shift 2;;
    --)
      break;;
     *)
      printf "Unknown option %s\n" "$1"
      exit 1;;
  esac
done

set_home

install_missing_deps

enable_podman

create_dirs

create_certs

extract_exec ${YGGD_IMAGE} ${YGGD_EXEC}

extract_exec ${DEVICE_WORKER_IMAGE} ${DEVICE_WORKER_EXEC}

copy_agent

create_yggd_service ${apiserver}

sudo systemctl daemon-reload
sudo systemctl enable yggd.service
sudo systemctl start yggd.service
