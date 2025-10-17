Import-Module Chocolatey-AU

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

    $version = $jsonAnswer.tag_name.replace("v", "")
    $url64 = "https://download.docker.com/win/static/stable/x86_64/docker-$version.zip"

    $release_notes = $jsonAnswer.html_url

    return @{
        Version      = $version;
        URL64        = $url64;
        ReleaseNotes = $release_notes;
    }
}

function global:au_SearchReplace {
    @{
        "tools\chocolateyInstall.ps1"     = @{
            "(^\s*Url64bit)\s*=.*"   = "`${1} = '$($Latest.URL64)'"
            "(^\s*Checksum64)\s*=.*" = "`${1} = '$($Latest.Checksum64)'"
        }

        ".\$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$( $Latest.ReleaseNotes )`$2"
        }
    }
}

Update-Package -ChecksumFor 64
