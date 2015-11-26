#!/bin/bash

CONFIG_FILE="$HOME/.docker/vm.config"
[[ -f $CONFIG_FILE ]] && source $CONFIG_FILE

if [ "$PROVIDER" == "VMWare Fusion" ]; then
  PROVIDER_CLI=/usr/local/bin/vmrun
  STATUS_CMD="list | grep"
  PROVIDER_PREFIX=vmwarefusion
elif [ "$PROVIDER" == "Parallels Desktop" ]; then
  PROVIDER_CLI=/usr/local/bin/prlctl
  STATUS_CMD=status
  PROVIDER_PREFIX=parallels
  echo -e "\nIf you haven't install the docker-machine-parallels driver,\ncheck: https://github.com/Parallels/docker-machine-parallels/\n"
else
  PROVIDER="VirtualBox"
  PROVIDER_CLI=/Applications/VirtualBox.app/Contents/MacOS/VBoxManage
  STATUS_CMD=showvminfo
  PROVIDER_PREFIX=virtualbox
fi

VM=default
DOCKER_MACHINE=/usr/local/bin/docker-machine

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

unset DYLD_LIBRARY_PATH
unset LD_LIBRARY_PATH

clear

if [ ! -f $DOCKER_MACHINE ]; then
  echo "Docker Machine are not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

if [ ! -f $PROVIDER_CLI ]; then
  if [ "$PROVIDER" == "VMWare Fusion" ] || [ "$PROVIDER" == "Parallels Desktop" ]; then
    echo "$PROVIDER_CLI are not installed. Please make sure $PROVIDER's command line tool works properly and try again."
  else
    echo "$PROVIDER are not installed. Please re-run the Toolbox Installer and try again."
  fi
  exit 1
fi

$PROVIDER_CLI $STATUS_CMD $VM &> /dev/null
VM_EXISTS_CODE=$?

if [ $VM_EXISTS_CODE -eq 0 ]; then
  echo "Machine $VM already exists in $PROVIDER."
else
  echo "Creating Machine $VM..."
  $DOCKER_MACHINE rm -f $VM &> /dev/null
  rm -rf ~/.docker/machine/machines/$VM
  $DOCKER_MACHINE create -d $PROVIDER_PREFIX --$PROVIDER_PREFIX-memory 2048 --$PROVIDER_PREFIX-disk-size 204800 $VM
fi

VM_STATUS=$($DOCKER_MACHINE status $VM)
if [ "$VM_STATUS" != "Running" ]; then
  echo "Starting machine $VM..."
  $DOCKER_MACHINE start $VM
  yes | $DOCKER_MACHINE regenerate-certs $VM
fi

echo "Setting environment variables for machine $VM..."
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

eval $($DOCKER_MACHINE env $VM --shell=bash)

USER_SHELL=$(dscl /Search -read /Users/$USER UserShell | awk '{print $2}' | head -n 1)
if [[ $USER_SHELL == *"/bash"* ]] || [[ $USER_SHELL == *"/zsh"* ]] || [[ $USER_SHELL == *"/sh"* ]]; then
  $USER_SHELL --login
else
  $USER_SHELL
fi
