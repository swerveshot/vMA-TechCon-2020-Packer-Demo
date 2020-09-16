<#

Powershell wrapper for building Packer virtual machine templates
This script allows for quick deployment of VM templates without learning all Packer's parameters

Main features:
* Simulate the script without actually running the packer build process
* Verbose output of both the script and packer itself via the built-in with powershell verbose parameter
* Select the types/names to be used for the builds; i.e. vmware-iso, hyperv-iso, virtualbox-iso or a named builder definition

#>

param (
    [Parameter(Mandatory=$true)] [string[]]$Path,
    [Parameter(mandatory=$false)] [string[]]$Only,
    [Parameter(mandatory=$false)] [switch]$Simulate
    );

# Testing if specified path exists
if(-Not (Test-Path $Path)) {
    Write-Error "Template file does not exist, exiting."
    exit $lastexitcode
}

# Setting variable file to template path and append '-variables.json'
$Varfile = [IO.Path]::GetDirectoryName($path) + "\" + [IO.Path]::GetFileNameWithoutExtension($path) + "-variables.json"
if(-Not (Test-Path $Varfile)) {
    Write-Error "Variable file does not exist, exiting."
    exit $lastexitcode
}

# Clearing previously set environment variable
if (Test-Path Env:PACKER_LOG) {
    Remove-Item Env:PACKER_LOG
}

# For verbose output set PACKER_LOG to 1 instead of 0
if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent){
    $Env:PACKER_LOG=1
    Write-Verbose "***** Display variables"
    Write-Verbose "-----------------------------"
    Write-Verbose "Path: $Path"
    Write-Verbose "Only: $Only"
    Write-Verbose "Varfile: $Varfile"
    Write-Verbose "Env:PACKER_LOG: $Env:PACKER_LOG"
    Write-Verbose "-----------------------------"
}

# Only run the build on specified names. Build names by default are their type, unless a specific name attribute is specified within the configuration.
if($Only) {
    $Only = "-only $Only"
}

if ($Simulate) {
    Write-Output "***** SIMULATE Deploying virtual machine template"
}
else {
    Write-Output "***** Deploying virtual machine template"
    Start-Process "packer" -ArgumentList "build $Only -timestamp-ui -var-file=$Varfile $Path" -Wait -NoNewWindow
}