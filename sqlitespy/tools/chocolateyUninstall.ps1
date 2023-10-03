
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$pkgPath = Split-Path -Parent -Path $toolsdir

# Clean up shortcuts
[Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('CommonPrograms') | ForEach-Object {
    Remove-Item -Path (Join-Path -Path $_ -ChildPath 'SQLiteSpy.lnk') -ErrorAction SilentlyContinue
}

# get the name of the file created by Install-ChocolateyZipPackage
$zipFilename = (Get-Item -Path (Join-Path -Path $pkgPath -ChildPath '*.zip.txt') | Select-Object -First 1).Basename
Uninstall-ChocolateyZipPackage -PackageName $env:ChocolateyPackageName -ZipFileName $zipFilename
