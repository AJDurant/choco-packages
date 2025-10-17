Import-Module Chocolatey-AU

$name64 = "SQLiteSpy.zip"
$releaseUrl = "https://www.yunqa.de/delphi/apps/sqlitespy/history"

function global:au_GetLatest {
    $headers = @{}

    $historyHTML = Invoke-RestMethod `
        -Uri $releaseUrl `
        -Headers $headers `
        -UseBasicParsing

    # Decode HTML entities to catch &ndash; etc.
    $decoded = [System.Net.WebUtility]::HtmlDecode($historyHTML)

    # Pattern: <h2 ... id="sqlitespy_v1930_1_jul_2025">SQLiteSpy v1.9.30 – 1 Jul 2025</h2>
    $pattern = '(?is)<h2[^>]*id="sqlitespy_v(?<vercode>\d+)[^"]*"[^>]*>\s*SQLiteSpy\s+v(?<ver>\d+(?:\.\d+){1,3})\s*(?:–|-)\s*(?<date>[^<]+)</h2>'
    $m = [regex]::Match($decoded, $pattern)
    if (-not $m.Success) { throw "Could not find the latest <h2> entry with id='sqlitespy_v...'." }

    $version = $m.Groups['ver'].Value
    $url64 = "https://www.yunqa.de/delphi/downloads/SQLiteSpy_v$version.zip"

    return @{
        Version    = $version;
        URL64      = $url64;
        Name64     = $name64;
        Checksum64 = Get-RemoteChecksum $url64;
    }
}

function global:au_BeforeUpdate() {
    $destinationPath = Join-Path ".\tools\" $Latest.Name64
    Start-BitsTransfer -Source $Latest.URL64 -Destination $destinationPath
}

function global:au_SearchReplace {
    @{
        ".\legal\VERIFICATION.txt" = @{
            "(?i)(\s+x64:).*"     = "`${1} $( $Latest.URL64 )"
            "(?i)(checksum64:).*" = "`${1} $( $Latest.Checksum64 )"
        }
    }
}

Update-Package -ChecksumFor none
