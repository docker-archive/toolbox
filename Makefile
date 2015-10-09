DOCKER_OSX_IMAGE := osx-installer
DOCKER_WINDOWS_IMAGE := windows-installer
DOCKER_OSX_CONTAINER := build-osx-installer
DOCKER_WINDOWS_CONTAINER := build-windows-installer
SIGNING_SERVER := $(signing_server)

default: osx windows win32
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

win32: clean-win32
	docker build -t $(DOCKER_WINDOWS_IMAGE) -f Dockerfile.win32 .
	docker run --name "$(DOCKER_WINDOWS_CONTAINER)" "$(DOCKER_WINDOWS_IMAGE)"
	mkdir -p dist
	docker cp "$(DOCKER_WINDOWS_CONTAINER)":/installer/Output/DockerToolbox.exe dist/DockerToolbox_x86.exe
	docker rm "$(DOCKER_WINDOWS_CONTAINER)" 2>/dev/null || true

clean-osx:
	rm -f DockerToolbox-*.pkg
	docker rm "$(DOCKER_OSX_CONTAINER)" 2>/dev/null || true

clean-windows:
	rm -f DockerToolbox-*.exe
	docker rm "$(DOCKER_WINDOWS_CONTAINER)" 2>/dev/null || true

clean-win32:
	rm -f DockerToolbox-*.exe
	docker rm "$(DOCKER_WINDOWS_CONTAINER)" 2>/dev/null || true
