
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. "$toolsDir\helper.ps1"
Test-DockerdConflict

$pp = Get-PackageParameters

if ( !$pp.DockerGroup ) {
    $pp.DockerGroup = "docker-users"
}

$dockerdPath = Join-Path $env:ProgramFiles "docker\dockerd.exe"
$groupUser = $env:USER_NAME

$packageArgs = @{
    PackageName    = $env:ChocolateyPackageName
    UnzipLocation  = $env:ProgramFiles
    Url64bit = 'https://download.docker.com/win/static/stable/x86_64/docker-28.5.2.zip'

    # You can also use checksum.exe (choco install checksum) and use it
    # e.g. checksum -t sha256 -f path\to\file
    Checksum64 = 'be76f32e6d92f4d3c64b8eb5e0e86e9597c00eb75ee41b5cc23e7674c5514810'
    ChecksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-zip-package

Install-BinFile -Name "docker" -Path "$env:ProgramFiles\docker\docker.exe"

# Set up user group for non admin usage
if (net localgroup | Select-String $($pp.DockerGroup) -SimpleMatch -Quiet) {
    Write-Host "$($pp.DockerGroup) group already exists"
}
else {
    net localgroup $($pp.DockerGroup) /add /comment:"Users of Docker"
}
if ( !$pp.noAddGroupUser ) {
    if (net localgroup $($pp.DockerGroup) | Select-String $groupUser -SimpleMatch -Quiet) {
        Write-Host "$groupUser already in $($pp.DockerGroup) group"
    }
    else {
        Write-Host "Adding $groupUser to $($pp.DockerGroup) group, you will need to log out and in to take effect"
        net localgroup $($pp.DockerGroup) $groupUser /add
    }
}

# Write config
$daemonConfig = @{"group" = $($pp.DockerGroup) }
$daemonFolder = "$env:ProgramData\docker\config\"
$daemonFile = Join-Path $daemonFolder "daemon.json"
if (Test-Path $daemonFile) {
    Write-Host "Config file '$daemonFile' already exists, not overwriting"
}
else {
    if (-not (Test-Path $daemonFolder)) {
        New-Item -ItemType Directory -Path $daemonFolder
    }
    $jsonContent = $daemonConfig | ConvertTo-Json -Depth 10
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [IO.File]::WriteAllLines($daemonFile, $jsonContent, $Utf8NoBomEncoding)
}

# From v23 the package is now installed in Program Files. So clean up old files/service from tools
if (Test-Path "$toolsDir\docker") {
    Write-Output "Cleaning up old docker files..."
    Remove-Item "$toolsDir\docker" -Recurse -Force
}
if (Test-OurOldDockerd) {
    Write-Output "Unregistering old docker service..."
    Start-ChocolateyProcessAsAdmin -Statements "delete docker" "C:\Windows\System32\sc.exe"
}

# Install service if not already there, conflict check at start also means no others.
if (-not (Test-OurDockerd)) {
    $scArgs = "create docker binpath= `"$dockerdPath --run-service`" start= auto displayname= `"$($env:ChocolateyPackageTitle)`""
    Start-ChocolateyProcessAsAdmin -Statements "$scArgs" "C:\Windows\System32\sc.exe"
}

if (!$pp.StartService) {
    Write-Host "$($env:ChocolateyPackageTitle) service created, start with: `sc start docker` "
}
else {
    Write-Output "Starting docker service..."
    Start-ChocolateyProcessAsAdmin -Statements "start docker" "C:\Windows\System32\sc.exe"
}
