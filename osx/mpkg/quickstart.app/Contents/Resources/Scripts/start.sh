#!/bin/bash

VM=default
DOCKER_MACHINE=/usr/local/bin/docker-machine
VBOXMANAGE=/Applications/VirtualBox.app/Contents/MacOS/VBoxManage

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

unset DYLD_LIBRARY_PATH
unset LD_LIBRARY_PATH

clear

if [ ! -f $DOCKER_MACHINE ] || [ ! -f $VBOXMANAGE ]; then
  echo "Either VirtualBox or Docker Machine are not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

$VBOXMANAGE showvminfo $VM &> /dev/null
VM_EXISTS_CODE=$?

if [ $VM_EXISTS_CODE -eq 1 ]; then
  echo "Creating Machine $VM..."
  $DOCKER_MACHINE rm -f $VM &> /dev/null
  rm -rf ~/.docker/machine/machines/$VM
  $DOCKER_MACHINE create -d virtualbox --virtualbox-memory 2048 --virtualbox-disk-size 204800 $VM
else
  echo "Machine $VM already exists in VirtualBox."
fi

VM_STATUS=$($DOCKER_MACHINE status $VM 2>&1)
if [ "$VM_STATUS" != "Running" ]; then
  echo "Starting machine $VM..."
  $DOCKER_MACHINE start $VM
  yes | $DOCKER_MACHINE regenerate-certs $VM
fi

echo "Replacing VBoxfs mounts with NFS"
if test -f "/etc/nfs.conf"; then sudo sed -i '' '/nfs.server.mount.require_resv_port/d' /etc/nfs.conf; fi
if test -f "/etc/exports"; then sudo sed -i '' '/Users/d' /etc/exports; fi
echo 'nfs.server.mount.require_resv_port = 0' | sudo tee -a /etc/nfs.conf > /dev/null
echo /Users -mapall=$(whoami):staff $HOSTNAME | sudo tee -a /etc/exports > /dev/null
sudo nfsd restart

$DOCKER_MACHINE ssh $VM "sudo umount /Users; sudo /usr/local/etc/init.d/nfs-client restart; sudo mount $HOSTNAME:/Users /Users -o rw,async,noatime,rsize=32768,wsize=32768,proto=tcp;"

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
