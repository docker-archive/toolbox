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

& $dm rm -f $vm