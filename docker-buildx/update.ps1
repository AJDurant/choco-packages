Import-Module Chocolatey-AU

$name64 = "docker-buildx.exe"
$releaseUrl = "https://api.github.com/repos/docker/buildx/releases/latest"

function global:au_GetLatest {
    $headers = @{}
    if (Test-Path Env:\github_api_key) {
        $headers["Authorization"] = "token $Env:github_api_key"
    }

    $jsonAnswer = Invoke-RestMethod `
        -Uri $releaseUrl `
        -Headers $headers `
        -UseBasicParsing

    $jsonAnswer.assets | where { $_.name -match "^buildx-v[0-9.]+windows-amd64.exe$" } | ForEach-Object {
        $url64 = $_.browser_download_url
        $checksumtype64, $checksum64 = $_.digest.split(":")
    }

    $version = $jsonAnswer.tag_name.replace("v", "")

    $release_notes = $jsonAnswer.html_url

    return @{
        Version        = $version;
        URL64          = $url64;
        ChecksumType64 = $checksumtype64;
        Checksum64     = $checksum64;
        Name64         = $name64;
        ReleaseNotes   = $release_notes;
    }
}

function global:au_BeforeUpdate() {
    $executablePath = Join-Path ".\tools\" $Latest.Name64
    Start-BitsTransfer -Source $Latest.URL64 -Destination $executablePath
}

function global:au_SearchReplace {
    @{
        ".\legal\VERIFICATION.txt"        = @{
            "(?i)(\s+x64:).*"         = "`${1} $( $Latest.URL64 )"
            "(?i)(checksumtype64:).*" = "`${1} $( $Latest.ChecksumType64 )"
            "(?i)(checksum64:).*"     = "`${1} $( $Latest.Checksum64 )"
        }

        ".\$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$( $Latest.ReleaseNotes )`$2"
        }
    }
}

Update-Package -ChecksumFor none
