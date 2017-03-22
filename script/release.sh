#!/bin/sh

set -e

if [ -z "${GITHUB_TOKEN}" ];
then
	echo "Must specify GITHUB_TOKEN."
	exit 1
fi

. versions

case $1 in
create)
	git fetch --tags
	git tag "${INSTALLER_VERSION}"
	git push git@github.com:docker/toolbox "${INSTALLER_VERSION}"

	github-release release \
		--user docker \
		--repo toolbox \
		--tag "${INSTALLER_VERSION}" \
		--name "${INSTALLER_VERSION}" \
		--description "Please ensure that your system has all of the latest
updates before attempting the installation.  In some cases, this will require a
reboot.  If you run into issues creating VMs, you may need to uninstall
VirtualBox before re-installing the Docker Toolbox.

The following list of components is included with this Toolbox release.  If you
have a previously installed version of Toolbox, these installers will update
the components to these versions.

**Included Components**
- docker `${DOCKER_VERSION}`
- docker-machine `${DOCKER_MACHINE_VERSION}`
- docker-compose `${DOCKER_COMPOSE_VERSION}`
- Kitematic `${KITEMATIC_VERSION}`
- Boot2Docker ISO `${DOCKER_VERSION}`
- VirtualBox `${VBOX_VERSION}`" \
		--pre-release
	;;
rm)
	# delete github release
	github-release delete \
		--user docker \
		--repo toolbox \
		--tag "${INSTALLER_VERSION}"

	# delete tag.
	git push git@github.com ":${INSTALLER_VERSION}"
	;;
*)
	echo "Usage: ./script/release.sh [create|rm]"
	exit 1
esac
