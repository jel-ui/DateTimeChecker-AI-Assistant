$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$secretDirectory = Join-Path $root ".secrets"
$secretPath = Join-Path $secretDirectory "gemini-api-key.txt"

if (Test-Path -LiteralPath $secretPath) {
    Remove-Item -LiteralPath $secretPath -Force
    Write-Output "Đã xóa Gemini API key được lưu cục bộ."
} else {
    Write-Output "Chưa có Gemini API key cục bộ để xóa."
}

if ((Test-Path -LiteralPath $secretDirectory) -and -not (Get-ChildItem -LiteralPath $secretDirectory -Force)) {
    Remove-Item -LiteralPath $secretDirectory -Force
}
