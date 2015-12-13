#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong... Press any key to continue..."' EXIT

VM=default
DOCKER_MACHINE=./docker-machine.exe

if [ ! -z "$VBOX_MSI_INSTALL_PATH" ]; then
  VBOXMANAGE=${VBOX_MSI_INSTALL_PATH}VBoxManage.exe
else
  VBOXMANAGE=${VBOX_INSTALL_PATH}VBoxManage.exe
fi

BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f $DOCKER_MACHINE ] || [ ! -f "${VBOXMANAGE}" ]; then
  echo "Either VirtualBox or Docker Machine are not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

"${VBOXMANAGE}" showvminfo $VM &> /dev/null
VM_EXISTS_CODE=$?

set -e

if [ $VM_EXISTS_CODE -eq 1 ]; then
  echo "Creating Machine $VM..."
  $DOCKER_MACHINE rm -y -f $VM &> /dev/null || :
  rm -rf ~/.docker/machine/machines/$VM
  $DOCKER_MACHINE create -d virtualbox $VM
else
  echo "Machine $VM already exists in VirtualBox."
fi

VM_STATUS=$($DOCKER_MACHINE status $VM)
if [ "$VM_STATUS" != "Running" ]; then
  echo "Starting machine $VM..."
  $DOCKER_MACHINE start $VM
  yes | $DOCKER_MACHINE regenerate-certs $VM
fi

echo "Setting environment variables for machine $VM..."
eval "$($DOCKER_MACHINE env --shell=bash $VM)"

clear
cat << EOF


                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

EOF
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}$VM${NC} machine with IP ${GREEN}$($DOCKER_MACHINE ip $VM)${NC}"
echo "For help getting started, check out the docs at https://docs.docker.com"
echo
cd

exec "$BASH" --login -i
