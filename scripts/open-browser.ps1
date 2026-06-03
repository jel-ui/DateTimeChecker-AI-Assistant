param(
    [string]$Url = "http://localhost:4173"
)

$ErrorActionPreference = "SilentlyContinue"
. (Join-Path $PSScriptRoot "common.ps1")

for ($attempt = 0; $attempt -lt 40; $attempt++) {
    if (Test-DateTimeCheckerAppServer -Url $Url) {
        Start-Process $Url
        exit 0
    }

    Start-Sleep -Milliseconds 250
}

exit 1
