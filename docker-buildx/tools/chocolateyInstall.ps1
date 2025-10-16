$ErrorActionPreference = "Stop"
$packageToolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$executablePath = Join-Path $packageToolsDir 'docker-buildx.exe'

$executableTargetDir = "$env:ProgramData\docker\cli-plugins\"
$executableTargetPath = Join-Path $executableTargetDir 'docker-buildx.exe'

# create plugin directory if it doesn't exist
if (-not (Test-Path -Path $executableTargetDir)) {
    $null = New-Item -Path $executableTargetDir -ItemType Directory
}

# move executable
Move-Item -Path $executablePath -Destination $executableTargetPath -Force
