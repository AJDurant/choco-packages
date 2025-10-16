
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. "$toolsDir\helper.ps1"
Test-ContainerdConflict

# Remove config keys added during install
$daemonFolder = "$env:ProgramData\docker\config\"
$daemonFile = Join-Path $daemonFolder "daemon.json"

If (Test-Path $daemonFile) {
    Write-Host "Found config file '$daemonFile', removing installed keys"

    try {
        $existingJson = Get-Content $daemonFile -Raw -Encoding UTF8
        $existingConfig = $existingJson | ConvertFrom-Json | ConvertTo-Hashtable

        $modified = $false

        # Remove "default-runtime" key
        if ($existingConfig.ContainsKey("default-runtime")) {
            $existingConfig.Remove("default-runtime")
            $modified = $true
            Write-Host "Removed key: default-runtime"
        }

        # Remove "containerd-snapshotter" from features, but keep features if it has other keys
        if ($existingConfig.ContainsKey("features") -and $existingConfig["features"] -is [hashtable]) {
            if ($existingConfig["features"].ContainsKey("containerd-snapshotter")) {
                $existingConfig["features"].Remove("containerd-snapshotter")
                $modified = $true
                Write-Host "Removed key: features.containerd-snapshotter"

                # If features is now empty, remove the entire features key
                if ($existingConfig["features"].Count -eq 0) {
                    $existingConfig.Remove("features")
                    Write-Host "Removed empty features dictionary"
                }
            }
        }

        if ($modified) {
            # Check if config is now empty
            if ($existingConfig.Count -eq 0) {
                Write-Host "Configuration is now empty, removing file '$daemonFile'"
                Remove-Item $daemonFile -Force

                # Remove directory if it's empty
                if ((Get-ChildItem $daemonFolder -Force | Measure-Object).Count -eq 0) {
                    Write-Host "Removing empty directory '$daemonFolder'"
                    Remove-Item $daemonFolder -Force
                }
            }
            else {
                # Write updated config back to file
                $jsonContent = $existingConfig | ConvertTo-Json -Depth 10
                $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
                [IO.File]::WriteAllLines($daemonFile, $jsonContent, $Utf8NoBomEncoding)
                Write-Host "Updated configuration written to '$daemonFile'"
            }
        }
        else {
            Write-Host "No keys to remove found in configuration"
        }
    }
    catch {
        Write-Warning "Failed to process config file: $_"
    }
}
Else {
    Write-Host "Config file '$daemonFile' does not exist, nothing to remove"
}

If (Test-OurContainerd) {
    Write-output "Unregistering containerd service..."
    Start-ChocolateyProcessAsAdmin -Statements "delete containerd" "C:\Windows\System32\sc.exe"
}

Uninstall-ChocolateyZipPackage $env:ChocolateyPackageName "containerd-windows-amd64.tar"
