
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

If ((Get-OSArchitectureWidth -compare 32) -or ($env:chocolateyForceX86 -eq $true)) {
    $folder = "win32"
}
Else {
    $folder = "win64"
}

$packageArgs = @{
    PackageName    = $env:ChocolateyPackageName
    FileFullPath   = "$toolsDir/SQLiteSpy_v1.9.19.zip"
    Destination    = $toolsDir
    SpecificFolder = $folder
}

Get-ChocolateyUnzip @packageArgs # https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip

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
    -targetPath (Join-Path -Path $toolsDir -ChildPath "./$folder/SQLiteSpy.exe")
