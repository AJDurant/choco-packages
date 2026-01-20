Import-Module Chocolatey-AU

$name64 = "docker.zip"
$releaseUrl = "https://api.github.com/repos/moby/moby/releases/latest"

function global:au_GetLatest {
    $headers = @{}
    if (Test-Path Env:\github_api_key) {
        $headers["Authorization"] = "token $Env:github_api_key"
    }

    $jsonAnswer = Invoke-RestMethod `
        -Uri $releaseUrl `
        -Headers $headers `
        -UseBasicParsing

    $version = $jsonAnswer.tag_name.replace("docker-v", "")
    $url64 = "https://download.docker.com/win/static/stable/x86_64/docker-$version.zip"

    $release_notes = $jsonAnswer.html_url

    return @{
        Version      = $version;
        URL64        = $url64;
        Name64       = $name64;
        Checksum64   = Get-RemoteChecksum $url64;
        ReleaseNotes = $release_notes;
    }
}

function global:au_BeforeUpdate() {
    $destinationPath = Join-Path ".\tools\" $Latest.Name64
    Start-BitsTransfer -Source $Latest.URL64 -Destination $destinationPath
}

function global:au_SearchReplace {
    @{
        ".\$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$( $Latest.ReleaseNotes )`$2"
        }
        ".\legal\VERIFICATION.txt"        = @{
            "(?i)(\s+x64:).*"     = "`${1} $( $Latest.URL64 )"
            "(?i)(checksum64:).*" = "`${1} $( $Latest.Checksum64 )"
        }
    }
}

Update-Package -ChecksumFor none
