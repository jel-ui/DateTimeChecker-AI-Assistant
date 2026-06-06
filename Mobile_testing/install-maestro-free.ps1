$ErrorActionPreference = "Stop"

Write-Output "Installing Maestro CLI using the official installer..."
Write-Output "Source: https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip"
Write-Output ""

$maestroDir = Join-Path $env:USERPROFILE ".maestro"
$tmpDir = Join-Path $maestroDir "tmp"
$zipPath = Join-Path $tmpDir "maestro.zip"

New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
curl.exe -fL "https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip" -o $zipPath

if (Test-Path -LiteralPath (Join-Path $maestroDir "bin")) {
    Remove-Item -LiteralPath (Join-Path $maestroDir "bin") -Recurse -Force
}
if (Test-Path -LiteralPath (Join-Path $maestroDir "lib")) {
    Remove-Item -LiteralPath (Join-Path $maestroDir "lib") -Recurse -Force
}

Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpDir -Force
Copy-Item -Path (Join-Path $tmpDir "maestro\*") -Destination $maestroDir -Recurse -Force

Write-Output ""
Write-Output "Maestro install finished."
Write-Output "Binary: $(Join-Path $maestroDir 'bin\maestro.bat')"
