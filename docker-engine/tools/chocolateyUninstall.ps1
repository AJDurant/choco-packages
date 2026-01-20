
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$pkgPath = Split-Path -Parent -Path $toolsdir
. "$toolsDir\helper.ps1"
Test-DockerdConflict

if (Test-OurDockerd) {
  Write-Output "Unregistering docker service..."
  Start-ChocolateyProcessAsAdmin -Statements "delete docker" "C:\Windows\System32\sc.exe"
}

Uninstall-BinFile -Name "docker"
$zipFilename = (Get-Item -Path (Join-Path -Path $pkgPath -ChildPath '*.zip.txt') | Select-Object -First 1).Basename
Uninstall-ChocolateyZipPackage -PackageName $env:ChocolateyPackageName -ZipFileName $zipFilename
