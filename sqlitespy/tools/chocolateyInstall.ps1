
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = "https://www.yunqa.de/delphi/downloads/SQLiteSpy_v1.9.19.zip" # download url, HTTPS preferred

$packageArgs = @{
    PackageName    = $env:ChocolateyPackageName
    UnzipLocation  = $toolsDir
    SpecificFolder = "win64"
    Url            = $url
    # You can also use checksum.exe (choco install checksum) and use it
    # e.g. checksum -t sha256 -f path\to\file
    Checksum       = 'A3942C4463287116A357E382721517F3225EECBA5CCEF580D5BD112A2BF01C44'
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
