
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = "https://www.yunqa.de/delphi/downloads/SQLiteSpy_v1.9.17.zip" # download url, HTTPS preferred

$packageArgs = @{
    PackageName    = $env:ChocolateyPackageName
    UnzipLocation  = $toolsDir
    SpecificFolder = "win64"
    Url            = $url
    # You can also use checksum.exe (choco install checksum) and use it
    # e.g. checksum -t sha256 -f path\to\file
    Checksum       = '07AF42452F67E5B2D31CFDFC479EF1A2B9734B73FCD24B94F20B5335BAF9D81F'
    ChecksumType   = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-zip-package

# Create GUI shims
$exeFiles = get-childitem $toolsDir -include *.exe -recurse
foreach ($file in $exeFiles) {
    #generate a gui shim file
    New-Item "$file.gui" -type file -force | Out-Null
}

# Start menu shortcuts
$progsFolder = [Environment]::GetFolderPath('Programs')
If ( Test-ProcessAdminRights ) {
    $progsFolder = [Environment]::GetFolderPath('CommonPrograms')
}

Install-ChocolateyShortcut -shortcutFilePath (Join-Path -Path $progsFolder -ChildPath 'SQLiteSpy.lnk') `
    -targetPath (Join-Path -Path $toolsDir -ChildPath "./win64/SQLiteSpy.exe")
