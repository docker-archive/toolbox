#requires -Version 3
<#
        .Synopsis
        Gets docker ready to use
#>
[CmdletBinding()]
[Alias()]
Param
(
    # Name of the VM to use
    [string]$vm = 'default'
)

$dm = Join-Path -Path $PSScriptRoot -ChildPath 'docker-machine.exe'

Write-Verbose -Message "VM: $vm"
Write-Verbose -Message "docker-machine: $dm"

if (Test-Path -Path 'Env:VBOX_MSI_INSTALL_PATH')
{
    $vbm = (Join-Path -Path $env:VBOX_MSI_INSTALL_PATH -ChildPath 'VBoxManage.exe')
}
else
{
    $vbm = (Join-Path -Path $env:VBOX_INSTALL_PATH -ChildPath 'VBoxManage.exe')
}

Write-Verbose -Message "vboxmanage: $vbm"

if (-not (Test-Path $dm) -or -not (Test-Path $vbm))
{
    throw 'Either VirtualBox or Docker Machine are not installed. Please re-run the Toolbox Installer and try again.'
}

& $vbm showvminfo $vm *> $null
$vmExistsCode = $LASTEXITCODE

if ($vmExistsCode -ne 0)
{
    Write-Host -Object "Creating Machine $vm..."
    & $dm rm -f $vm *> $null
    Remove-Item -Force -Recurse -Path "~/.docker/machine/machines/$vm" -ErrorAction SilentlyContinue
    & $dm create -d virtualbox $vm
}
else
{
    Write-Host -Object "Machine $vm already exists in VirtualBox."
}

$vm_status = (& $dm status $vm)
if ($vm_status -ne 'Running')
{
    Write-Host -Object "Starting machine $vm..."
    & $dm start $vm
    'yes' | & $dm regenerate-certs $vm
}

Write-Host -Object "Setting environment variables for machine $vm..."
$dockerEnv = (& $dm env --shell=powershell $vm)
$dockerEnv | ForEach-Object -Process {
    Write-Verbose -Message $_
}
$dockerEnv | Invoke-Expression

#Clear-Host
Write-Host -Object @"


                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

"@
Write-Host -Object 'docker ' -NoNewline -ForegroundColor Blue
Write-Host -Object 'is configured to use the ' -NoNewline
Write-Host -Object $vm -ForegroundColor Green -NoNewline
Write-Host -Object ' machine with IP ' -NoNewline
Write-Host -Object (& $dm ip $vm) -ForegroundColor Green
Write-Host -Object 'For help getting started, check out the docs at https://docs.docker.com'
