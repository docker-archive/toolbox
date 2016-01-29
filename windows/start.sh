#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong... Press any key to continue..."' EXIT

VM=default
DOCKER_MACHINE=./docker-machine.exe

if [ ! -z "$VBOX_MSI_INSTALL_PATH" ]; then
  VBOXMANAGE="${VBOX_MSI_INSTALL_PATH}VBoxManage.exe"
else
  VBOXMANAGE="${VBOX_INSTALL_PATH}VBoxManage.exe"
fi

BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "${DOCKER_MACHINE}" ] || [ ! -f "${VBOXMANAGE}" ]; then
  echo "Either VirtualBox or Docker Machine are not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

"${VBOXMANAGE}" list vms | grep \""${VM}"\" &> /dev/null
VM_EXISTS_CODE=$?

set -e

if [ $VM_EXISTS_CODE -eq 1 ]; then
  "${DOCKER_MACHINE}" rm -f "${VM}" &> /dev/null || :
  rm -rf ~/.docker/machine/machines/"${VM}"
  "${DOCKER_MACHINE}" create -d virtualbox "${VM}"
fi

VM_STATUS="$(${DOCKER_MACHINE} status ${VM} 2>&1)"
if [ "${VM_STATUS}" != "Running" ]; then
  "${DOCKER_MACHINE}" start "${VM}"
  yes | "${DOCKER_MACHINE}" regenerate-certs "${VM}"
fi

eval "$(${DOCKER_MACHINE} env --shell=bash ${VM})"

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
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM}${NC} machine with IP ${GREEN}$(${DOCKER_MACHINE} ip ${VM})${NC}"
echo "For help getting started, check out the docs at https://docs.docker.com"
echo
cd

# Test if the Docker client in the path is the one in the Docker toolbox dir
DOCKER_EXE="docker"
# need to use the short DOS path, and then convert to cygwin path - some scripting fails executing with spaces
DOCKER_PATH=$(cygpath.exe -u "$(cygpath.exe -d "$DOCKER_TOOLBOX_INSTALL_PATH")")

TEST_DOCKER_VERSION="$(docker -v)"
TEST_DOCKER_TOOLBOX_VERSION="$($DOCKER_PATH/docker.exe -v)"

if [ "$TEST_DOCKER_VERSION" != "$TEST_DOCKER_TOOLBOX_VERSION" ]; then
	echo "adding toolbox dir to begining of PATH to avoid using $TEST_DOCKER_VERSION at $(which docker)"
	DOCKER_EXE="$DOCKER_PATH/docker.exe"
	PATH="$DOCKER_PATH:$PATH"
	export PATH
fi

docker () {
  MSYS_NO_PATHCONV=1 docker.exe $@
}
export -f docker

exec "${BASH}" --login -i
