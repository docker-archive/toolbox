Docker Toolbox

### TL/DR: Docker will be ceasing Support and Development of the Docker Toolbox project in 2020 - going forward please use [Docker Desktop](https://www.docker.com/products/docker-desktop)

Docker released the Docker Toolbox project to make it easier for developers who work on Mac and Windows to get started using Docker. In 2016 Docker released Docker Desktop which superseded toolbox and was significantly easier for the majority of users to get started.  This still left some users behind, predominantly users who were on Windows Home editions, Windows 7, Windows 8 and users of Virtualbox. 
Since 2016 there have been a number of changes. Windows 7 is no longer supported and the mainstream support of Windows 8.1 has ended. The majority of Windows users now on a version of Windows 10.  Since [Virtualbox 6.0](https://docs.oracle.com/en/virtualization/virtualbox/6.0/admin/hyperv-support.html#:~:text=Oracle%20VM%20VirtualBox%20can%20be,engine%20for%20the%20host%20system) users have been able to run virtualbox and HyperV at the same time on their Windows machines, allowing users to use virtualbox and Docker Desktop side by side on HyperV. For Windows Home users, WSL 2 is available and Docker Desktop now uses this to provide [Desktop for Windows Home](https://docs.docker.com/docker-for-windows/install-windows-home/)

Given these changes Docker has decided to archive the Toolbox project to allow us to make it clear that we are no longer supporting or developing this product and to give us time to focus on making further improvements to Docker Desktop.
Please provide any feedback via the [Docker Public Roadmap](https://github.com/docker/roadmap/issues/110)

==================================

[![docker toolbox logo](https://cloud.githubusercontent.com/assets/251292/9585188/2f31d668-4fca-11e5-86c9-826d18cf45fd.png)](https://www.docker.com/toolbox)

The Docker Toolbox installs everything you need to get started with
Docker on Mac OS X and Windows. It includes the Docker client, Compose,
Machine, Kitematic, and VirtualBox.

## Installation and documentation

Documentation for Mac [is available here](https://docs.docker.com/toolbox/toolbox_install_mac/).

Documentation for Windows [is available here](https://docs.docker.com/toolbox/toolbox_install_windows/). 

*Note:* Some Windows and Mac computers may not have VT-X enabled by default. It is required for VirtualBox. To check if VT-X is enabled on Windows follow this guide [here](http://amiduos.com/support/knowledge-base/article/how-can-i-get-to-know-my-processor-supports-virtualization-technology). To enable VT-X on Windows, please see the guide [here](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware). To enable VT-X on Intel-based Macs, refer to this Apple guide [here](https://support.apple.com/en-us/HT203296).
Also note that if the Virtual Machine was created before enabling VT-X it can be necessary to remove and reinstall the VM for Docker Toolbox to work.

Toolbox is currently unavailable for Linux; To get started with Docker on Linux, please follow the Linux [Getting Started Guide](https://docs.docker.com/linux/started/).

## Building the Docker Toolbox

Toolbox installers are built using Docker, so you'll need a Docker host set up. For example, using [Docker Machine](https://github.com/docker/machine):

```
$ docker-machine create -d virtualbox toolbox
$ eval "$(docker-machine env toolbox)"
```

Then, to build the Toolbox for both platforms:

```
make
```

Build for a specific platform:

```
make osx
```

or

```
make windows
```

The resulting installers will be in the `dist` directory.

## Frequently Asked Questions

**Do I have to install VirtualBox?**

No, you can deselect VirtualBox during installation. It is bundled in case you want to have a working environment for free.
