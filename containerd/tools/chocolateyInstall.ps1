
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. "$toolsDir\helper.ps1"
Test-ContainerdConflict

$url = "https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-windows-amd64.tar.gz"

$pp = Get-PackageParameters

$containerdPath = Join-Path $env:ProgramFiles "containerd/bin/containerd.exe"

$downloadArgs = @{
    PackageName  = $env:ChocolateyPackageName
    FileFullPath = "$toolsDir/containerd-windows-amd64.tar.gz"
    Url          = $url

    # You can also use checksum.exe (choco install checksum) and use it
    # e.g. checksum -t sha256 -f path\to\file
    Checksum     = '2C50AEB1E6D9AD513E986408EA066919318F14271C5A1B952F118878ECFA6A56'
    ChecksumType = 'sha256'
}

Get-ChocolateyWebFile @downloadArgs
$File = Get-ChildItem -File -Path "$toolsDir/containerd-windows-amd64.tar.gz"
Get-ChocolateyUnzip -FileFullPath $File.FullName -Destination $toolsDir

$packageArgs = @{
    PackageName   = $env:ChocolateyPackageName
    File          = "$toolsDir/containerd-windows-amd64.tar"
    UnzipLocation = "$env:ProgramFiles/containerd"
}
Get-ChocolateyUnzip @packageArgs # https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip/


# Write config
$daemonConfig = @{
    "default-runtime" = "io.containerd.runhcs.v1";
    "features"        = @{
        "containerd-snapshotter" = $True
    }
}
$daemonFolder = "$env:ProgramData\docker\config\"
$daemonFile = Join-Path $daemonFolder "daemon.json"

# Ensure directory exists
If (-not (Test-Path $daemonFolder)) {
    New-Item -ItemType Directory -Path $daemonFolder
}

# Read existing config or create empty hashtable
$existingConfig = @{}
If (Test-Path $daemonFile) {
    Write-Host "Config file '$daemonFile' exists, merging configuration"
    try {
        $existingJson = Get-Content $daemonFile -Raw -Encoding UTF8
        $existingConfig = $existingJson | ConvertFrom-Json | ConvertTo-Hashtable
    }
    catch {
        Write-Warning "Failed to parse existing config, creating new one: $_"
        $existingConfig = @{}
    }
}

# Merge configurations (new config takes precedence)
foreach ($key in $daemonConfig.Keys) {
    if ($existingConfig.ContainsKey($key) -and $existingConfig[$key] -is [hashtable] -and $daemonConfig[$key] -is [hashtable]) {
        # Merge nested hashtables
        foreach ($nestedKey in $daemonConfig[$key].Keys) {
            $existingConfig[$key][$nestedKey] = $daemonConfig[$key][$nestedKey]
        }
    }
    else {
        # Replace or add new key
        $existingConfig[$key] = $daemonConfig[$key]
    }
}

# Write merged config
$jsonContent = $existingConfig | ConvertTo-Json -Depth 10
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[IO.File]::WriteAllLines($daemonFile, $jsonContent, $Utf8NoBomEncoding)
Write-Host "Updated configuration written to '$daemonFile'"

# Install service if not already there, conflict check at start also means no others.
If (-not (Test-OurContainerd)) {
    $scArgs = "create containerd binpath= `"$containerdPath --run-service`" start= auto displayname= `"$($env:ChocolateyPackageTitle)`""
    Start-ChocolateyProcessAsAdmin -Statements "$scArgs" "C:\Windows\System32\sc.exe"
}

If (!$pp.StartService) {
    Write-Host "$($env:ChocolateyPackageTitle) service created, start with: `sc start containerd` "
}
Else {
    Write-output "Starting containerd service..."
    Start-ChocolateyProcessAsAdmin -Statements "start containerd" "C:\Windows\System32\sc.exe"
}
