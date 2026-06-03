. (Join-Path $PSScriptRoot "common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$url = "http://localhost:4173"
$previousLocation = Get-Location

if (Test-DateTimeCheckerAppServer -Url $url) {
    Write-Output "Date Time Checker đang chạy tại $url"
    Write-Output "Đang mở lại ứng dụng trên trình duyệt..."
    Start-Process $url
    exit 0
}

if (-not (Test-TcpPortAvailable -Port 4173)) {
    throw "Port 4173 đang được dùng bởi server không đúng phiên bản hiện tại. Hãy đóng cửa sổ run.bat cũ rồi chạy lại."
}

& (Join-Path $PSScriptRoot "build.ps1")
$tools = Get-JavaTools

try {
    Set-Location -LiteralPath $root
    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$(Join-Path $PSScriptRoot 'open-browser.ps1')`"", "-Url", $url `
        -WindowStyle Hidden
    Write-Output "Đang khởi động Date Time Checker..."
    Write-Output "Giữ cửa sổ này mở để sử dụng ứng dụng."
    & $tools.Java -cp "out\classes" com.datetimechecker.App
} finally {
    Set-Location -LiteralPath $previousLocation
}
