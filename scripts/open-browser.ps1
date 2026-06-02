param(
    [string]$Url = "http://localhost:4173"
)

$ErrorActionPreference = "SilentlyContinue"

for ($attempt = 0; $attempt -lt 40; $attempt++) {
    $response = Invoke-WebRequest -UseBasicParsing -Uri "$Url/" -TimeoutSec 2
    if ($response.StatusCode -eq 200 -and $response.Content.Contains("<title>Date Time Checker</title>")) {
        Start-Process $Url
        exit 0
    }

    Start-Sleep -Milliseconds 250
}

exit 1
