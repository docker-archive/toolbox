DOCKER_OSX_IMAGE := osx-installer
DOCKER_OSX_CONTAINER := build-osx-installer
DOCKER_WINDOWS_IMAGE := windows-installer
DOCKER_WINDOWS_CONTAINER := build-windows-installer
DOCKER_OSX_DOCKERCON_DEMOPACK_IMAGE := osx-dockercon-demopack-installer
DOCKER_OSX_DOCKERCON_DEMOPACK_CONTAINER := build-osx-dockercon-demopack-installer

default: osx windows
	@true

clean: clean-osx clean-windows clean-osx-dockercon-demopack
	@true

osx: clean-osx
	docker build -t $(DOCKER_OSX_IMAGE) -f Dockerfile.osx .
	docker run --name "$(DOCKER_OSX_CONTAINER)" "$(DOCKER_OSX_IMAGE)"
	mkdir -p dist
	docker cp "$(DOCKER_OSX_CONTAINER)":/DockerToolbox.pkg dist/
	docker rm "$(DOCKER_OSX_CONTAINER)" 2>/dev/null || true

windows: clean-windows
	docker build -t $(DOCKER_WINDOWS_IMAGE) -f Dockerfile.windows .
	docker run --name "$(DOCKER_WINDOWS_CONTAINER)" "$(DOCKER_WINDOWS_IMAGE)"
	mkdir -p dist
	docker cp "$(DOCKER_WINDOWS_CONTAINER)":/installer/Output/DockerToolbox.exe dist/
	docker rm "$(DOCKER_WINDOWS_CONTAINER)" 2>/dev/null || true

osx-dockercon-demopack: clean-osx-dockercon-demopack
	docker build -t $(DOCKER_OSX_DOCKERCON_DEMOPACK_IMAGE) -f Dockerfile.osx-dockercon-demopack .
	docker run --name "$(DOCKER_OSX_DOCKERCON_DEMOPACK_CONTAINER)" "$(DOCKER_OSX_DOCKERCON_DEMOPACK_IMAGE)"
	mkdir -p dist
	docker cp "$(DOCKER_OSX_DOCKERCON_DEMOPACK_CONTAINER)":/DockerToolbox.pkg dist/DockerToolbox-dockercon-demopack.pkg
	docker rm "$(DOCKER_OSX_DOCKERCON_DEMOPACK_CONTAINER)" 2>/dev/null || true


clean-osx:
	rm -f DockerToolbox-*.pkg
	docker rm "$(DOCKER_OSX_CONTAINER)" 2>/dev/null || true

clean-windows:
	rm -f DockerToolbox-*.exe
	docker rm "$(DOCKER_WINDOWS_CONTAINER)" 2>/dev/null || true

clean-osx-dockercon-demopack:
	rm -f DockerToolbox-dockercon-demopack.pkg
	docker rm "$(DOCKER_OSX_DOCKERCON_DEMOPACK_CONTAINER)" 2>/dev/null || true
