@ECHO OFF

REM This is needed  to ensure that binaries provided
REM by Docker Toolbox over-ride binaries provided by
REM Docker for Windows when launching using the Quickstart.
SET PATH=%DOCKER_TOOLBOX_INSTALL_PATH%;%PATH%
IF DEFINED DOCKER_MACHINE_NAME (
       SET VM=%DOCKER_MACHINE_NAME%
) ELSE SET VM=default
SET DOCKER_MACHINE=%DOCKER_TOOLBOX_INSTALL_PATH%\docker-machine.exe
SET VM_DIR=%HOMEDRIVE%%HOMEPATH%\.docker\machine\machines\%VM%

SET STEP=Looking for vboxmanage.exe
IF DEFINED VBOX_MSI_INSTALL_PATH (
       SET VBOXMANAGE=%VBOX_MSI_INSTALL_PATH%VBoxManage.exe
) ELSE SET VBOXMANAGE=%VBOX_INSTALL_PATH%VBoxManage.exe

REM clear all_proxy if not socks address
IF DEFINED ALL_PROXY IF %ALL_PROXY:~0:5% NEQ socks SET ALL_PROXY

IF NOT EXIST "%DOCKER_MACHINE%" (
  ECHO "Docker Machine is not installed. Please re-run the Toolbox Installer and try again." 
  EXIT /B 1
)

IF NOT EXIST "%VBOXMANAGE%" (
  ECHO "VirtualBox is not installed. Please re-run the Toolbox Installer and try again."
  EXIT /B 1
)

IF DEFINED VM_ITEM SET VM_ITEM
ECHO Looking if %VM% already exists...
(FOR /F "delims=" %%V IN ('""%VBOXMANAGE%" list vms | findstr "%VM%""') DO SET VM_ITEM=%%V) || EXIT /B 1

SET STEP=Checking if machine %VM% exists
IF NOT DEFINED VM_ITEM (
  "%DOCKER_MACHINE%" rm -f "%VM%" > NUL 2>&1 || CALL :reportError
  IF EXIST "%VM_DIR%" RMDIR /S /Q "%VM_DIR%" || CALL :reportError
  REM set proxy variables inside virtual docker machine if they exist in host environment
  IF DEFINED HTTP_PROXY SET PROXY_ENV=%PROXY_ENV% --engine-env HTTP_PROXY=%HTTP_PROXY%
  IF DEFINED HTTPS_PROXY SET PROXY_ENV=%PROXY_ENV% --engine-env HTTPS_PROXY=%HTTPS_PROXY%
  IF DEFINED NO_PROXY SET PROXY_ENV=%PROXY_ENV --engine-env NO_PROXY=%NO_PROXY%
  "%DOCKER_MACHINE%" create -d virtualbox %PROXY_ENV% "%VM%" || CALL :reportError
)

SET STEP=Checking status of %VM%
ECHO Checking status of %VM%...
(FOR /F %%V IN ('""%DOCKER_MACHINE%" status "%VM%""') DO SET VM_STATUS=%%V) || EXIT /B 1
IF ERRORLEVEL 0 IF "%VM_STATUS: =%" NEQ "Running" (
  "%DOCKER_MACHINE%" start "%VM%" || CALL :reportError
  ECHO y | "%DOCKER_MACHINE%" regenerate-certs "%VM%" || CALL :reportError
)

SET STEP=Setting env
REM for persistent environment variables, available in next sessions
ECHO Setting persistent environment variables, available in next sessions...
(FOR /F eol^=#^ tokens^=2^,3^ delims^=^"^=^   %%V IN ('""%DOCKER_MACHINE%" env --shell=bash --no-proxy "%VM%""') DO (
 (SETX %%V %%W) > NUL 2>&1
)) || EXIT /B 1
REM EXIT /B 1
REM for transient environment variables, available in current session
ECHO Setting transient environment variables, available in current session...
(FOR /F eol^=#^ tokens^=2^,3^ delims^=^"^=^   %%V IN ('""%DOCKER_MACHINE%" env --shell=bash --no-proxy "%VM%""') DO (SET %%V=%%W
)) || EXIT /B 1

SET STEP=Finalize
ECHO Determining the %VM%'s IP...
(FOR /F %%V IN ('""%DOCKER_MACHINE%" ip "%VM%""') DO SET IP=%%V) || EXIT /B 1
CLS
ECHO.
ECHO.
ECHO                        ##         .
ECHO                  ## ## ##        ==
ECHO               ## ## ## ## ##    ===
ECHO           /"""""""""""""""""\___/ ===
ECHO      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
ECHO           \______ o           __/
ECHO             \    \         __/
ECHO              \____\_______/
ECHO.

ECHO docker is configured to use the %VM% machine with IP %IP%
ECHO For help getting started, check out the docs at https://docs.docker.com
ECHO.
ECHO.

IF "%1"=="" (
  ECHO Start interactive shell
  CMD
) ELSE (
  ECHO Start shell with command
  CMD /K docker %*
)

GOTO:EOF

:reportError
ECHO Looks like something went wrong in step `%STEP%`... Press any key to continue...
PAUSE > NUL
GOTO:EOF