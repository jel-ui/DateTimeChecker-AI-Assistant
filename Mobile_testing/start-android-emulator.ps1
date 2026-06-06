param(
    [string]$EmulatorId = "flutter_emulator"
)

$ErrorActionPreference = "Stop"

$emulator = Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path -LiteralPath $emulator)) {
    throw "Android emulator.exe not found at $emulator"
}
if (-not (Test-Path -LiteralPath $adb)) {
    throw "adb.exe not found at $adb"
}

$devices = & $adb devices
if (@($devices | Where-Object { $_ -match "`tdevice$" }).Count -gt 0) {
    Write-Output "Android device/emulator is already connected."
    $devices
    exit 0
}

Write-Output "Starting Android emulator: $EmulatorId"
Start-Process -FilePath $emulator `
    -ArgumentList "-avd", $EmulatorId, "-no-snapshot-save" `
    -WindowStyle Hidden | Out-Null

Write-Output "Waiting for emulator to boot..."
& $adb wait-for-device

for ($attempt = 1; $attempt -le 90; $attempt++) {
    $boot = (& $adb shell getprop sys.boot_completed 2>$null).Trim()
    if ($boot -eq "1") {
        Write-Output "Emulator is ready."
        & $adb devices
        exit 0
    }
    Start-Sleep -Seconds 2
}

throw "Emulator did not finish booting in time."
