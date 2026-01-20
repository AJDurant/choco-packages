
$EditionId = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'EditionID').EditionId
$RunningOnNano = $False
If ($EditionId -ilike '*Nano*') {
    $RunningOnNano = $True
}

Function Test-ServicePath ($ServiceEXE, $FolderToCheck) {
    if ($RunningOnNano) {
        #The NANO TP5 Compatible Way:
        Return ([bool](@(wmic service | Where-Object { $_ -ilike "*$ServiceEXE*" }) -ilike "*$FolderToCheck*"))
    }
    Else {
        #The modern way:
        Return ([bool]((Get-WmiObject win32_service | Where-Object { $_.PathName -ilike "*$ServiceEXE*" } | Select-Object -expand PathName) -ilike "*$FolderToCheck*"))
    }
}

Function Test-OurContainerd {
    return (Test-ServicePath 'containerd.exe' "$env:ProgramFiles") -Or (Test-ServicePath 'containerd.exe' "$toolsDir")
}

Function Test-ContainerdConflict {
    If (-not (Test-OurContainerd) -AND (sc.exe query containerd | Select-String 'SERVICE_NAME: containerd' -SimpleMatch -Quiet)) {
        $ExistingContainerdInstancePath = Get-ItemProperty hklm:\system\currentcontrolset\services\* | Where-Object { ($_.ImagePath -ilike '*containerd.exe*') } | Select-Object -expand ImagePath
        Throw "You have requested that the containerd service be installed, but this system appears to have an instance of a containerd service configured for another folder ($ExistingContainerdInstancePath). You will need to remove that instance of containerd to use the one that comes with this package."
    }
}

Function Test-ContainerdRunning {
    return [bool](C:\Windows\System32\sc.exe query container | Select-String 'RUNNING' -SimpleMatch -Quiet)
}

Function Test-ContainerdStopped {
    return [bool](C:\Windows\System32\sc.exe query container | Select-String 'STOPPED' -SimpleMatch -Quiet)
}

# Poswrshell 5 doesn't produce a Hashtable from the JSON
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        ## Return null if the input is null. This can happen when calling the function
        ## recursively and a property is null
        if ($null -eq $InputObject) {
            return $null
        }

        ## Check if the input is an array or collection. If so, we also need to convert
        ## those types into hash tables as well. This function will convert all child
        ## objects into hash tables (if applicable)
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $object
                }
            )

            ## Return the array but don't enumerate it because the object may be pretty complex
            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject]) {
            ## If the object has properties that need enumeration
            ## Convert it to its own hash table and return it
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        }
        else {
            ## If the object isn't an array, collection, or other object, it's already a hash table
            ## So just return it.
            $InputObject
        }
    }
}
