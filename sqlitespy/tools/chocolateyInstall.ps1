
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

if ((Get-OSArchitectureWidth -compare 32) -or ($env:chocolateyForceX86 -eq $true)) {
    $folder = "win32"
}
else {
    $folder = "win64"
}

$packageArgs = @{
    PackageName    = $env:ChocolateyPackageName
    FileFullPath   = "$toolsDir/SQLiteSpy.zip"
    Destination    = $toolsDir
    SpecificFolder = $folder
}

Get-ChocolateyUnzip @packageArgs # https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip

# Create GUI shims
$exeFiles = Get-ChildItem $toolsDir -Include *.exe -Recurse
foreach ($file in $exeFiles) {
    #generate a gui shim file
    New-Item "$file.gui" -type file -Force | Out-Null
}

# Start menu shortcuts
$progsFolder = [Environment]::GetFolderPath('Programs')
if ( Test-ProcessAdminRights ) {
    $progsFolder = [Environment]::GetFolderPath('CommonPrograms')
}

Install-ChocolateyShortcut -shortcutFilePath (Join-Path -Path $progsFolder -ChildPath 'SQLiteSpy.lnk') `
    -targetPath (Join-Path -Path $toolsDir -ChildPath "./$folder/SQLiteSpy.exe")
