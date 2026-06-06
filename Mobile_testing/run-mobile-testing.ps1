param(
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$flutterApp = Join-Path $root "flutter_app"
$reportDir = Join-Path $root "reports"
$reportPath = Join-Path $reportDir "mobile-testing-report.txt"
$flowPath = Join-Path $root "date_time_checker_flow.yaml"
$apkOutputDir = Join-Path $flutterApp "build\app\outputs\flutter-apk"
$appId = "com.datetimechecker.date_time_checker"

function Resolve-CommandPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string[]]$Candidates = @()
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Write-Step {
    param([string]$Message)
    Write-Output ""
    Write-Output "== $Message =="
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string[]]$Arguments = @(),

        [string]$WorkingDirectory = "",

        [switch]$AllowFailure
    )

    Write-Host ""
    Write-Host "== $Title =="
    $previousLocation = Get-Location
    try {
        if ($WorkingDirectory) {
            Set-Location -LiteralPath $WorkingDirectory
        }

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = $FilePath
        $escapedArguments = @($Arguments | ForEach-Object {
            '"' + ($_.ToString().Replace('\', '\\').Replace('"', '\"')) + '"'
        })
        $process.StartInfo.Arguments = $escapedArguments -join " "
        $process.StartInfo.UseShellExecute = $false
        if ($WorkingDirectory) {
            $process.StartInfo.WorkingDirectory = $WorkingDirectory
        }
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        $process.StartInfo.CreateNoWindow = $true
        [void]$process.Start()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        $exitCode = $process.ExitCode
        $output = @()
        if ($stdout) {
            $output += ($stdout -split "`r?`n" | Where-Object { $_ -ne "" })
        }
        if ($stderr) {
            $output += ($stderr -split "`r?`n" | Where-Object { $_ -ne "" })
        }
        $output | ForEach-Object { Write-Host $_ }

        if (-not $AllowFailure -and $null -ne $exitCode -and $exitCode -ne 0) {
            throw "$Title failed with exit code $exitCode."
        }

        return @($output | ForEach-Object { $_.ToString() })
    } finally {
        Set-Location -LiteralPath $previousLocation
    }
}

if (-not (Test-Path -LiteralPath $reportDir)) {
    New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
}

$flutter = Resolve-CommandPath "flutter" @(
    "D:\Flutter\flutter\bin\flutter.bat"
)

$adb = Resolve-CommandPath "adb-not-from-path" @(
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe",
    "D:\scrcpy-win64-v4.0\adb.exe"
)

$maestro = Resolve-CommandPath "maestro" @(
    "$env:USERPROFILE\.maestro\bin\maestro.bat",
    "$env:USERPROFILE\.maestro\bin\maestro"
)

$log = New-Object System.Collections.Generic.List[string]
$log.Add("Mobile Testing Report")
$log.Add("=====================")
$log.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
$log.Add("Tool: Maestro")
$log.Add("App: flutter_app")
$log.Add("App ID: $appId")
$log.Add("")

try {
    if (-not $flutter) {
        throw "Flutter command not found. Please install Flutter or update the script candidate path."
    }
    if (-not $adb) {
        throw "ADB command not found. Please install Android SDK Platform Tools."
    }

    $flutterVersion = Invoke-LoggedCommand `
        -Title "Flutter version" `
        -FilePath $flutter `
        -Arguments @("--version", "--suppress-analytics")
    $log.Add("Flutter version:")
    $log.AddRange([string[]]$flutterVersion)
    $log.Add("")

    $devicesOutput = Invoke-LoggedCommand `
        -Title "Connected Android devices" `
        -FilePath $adb `
        -Arguments @("devices")
    $log.Add("ADB devices:")
    $log.AddRange([string[]]$devicesOutput)
    $log.Add("")

    $connectedDevices = @($devicesOutput | Where-Object { $_ -match "`tdevice$" })
    if ($connectedDevices.Count -eq 0) {
        throw "No Android emulator/device is connected. Start an emulator or connect a phone, then run again."
    }

    if (-not $DeviceId) {
        $DeviceId = ($connectedDevices[0] -split "`t")[0]
    }
    Write-Output "Using Android device: $DeviceId"
    $log.Add("Selected device: $DeviceId")
    $log.Add("")

    $flutterTestOutput = Invoke-LoggedCommand `
        -Title "Flutter unit/widget tests" `
        -FilePath $flutter `
        -Arguments @("test") `
        -WorkingDirectory $flutterApp
    $log.Add("Flutter test:")
    $log.AddRange([string[]]$flutterTestOutput)
    $log.Add("")

    $buildOutput = Invoke-LoggedCommand `
        -Title "Build debug APK" `
        -FilePath $flutter `
        -Arguments @("build", "apk", "--debug", "--split-per-abi") `
        -WorkingDirectory $flutterApp

    $abiOutput = Invoke-LoggedCommand `
        -Title "Detect Android ABI" `
        -FilePath $adb `
        -Arguments @("-s", $DeviceId, "shell", "getprop", "ro.product.cpu.abi")
    $deviceAbi = (@($abiOutput | Where-Object { $_.Trim() })[0]).Trim()
    $apkName = switch ($deviceAbi) {
        "x86_64" { "app-x86_64-debug.apk" }
        "arm64-v8a" { "app-arm64-v8a-debug.apk" }
        "armeabi-v7a" { "app-armeabi-v7a-debug.apk" }
        default { "app-debug.apk" }
    }
    $apkPath = Join-Path $apkOutputDir $apkName

    if (-not (Test-Path -LiteralPath $apkPath)) {
        throw "APK was not created at $apkPath"
    }
    Write-Output "Selected APK for ${deviceAbi}: $apkPath"
    $log.Add("Build APK:")
    $log.AddRange([string[]]$buildOutput)
    $log.Add("Selected ABI: $deviceAbi")
    $log.Add("Selected APK: $apkPath")
    $log.Add("")

    $uninstallOutput = Invoke-LoggedCommand `
        -Title "Uninstall existing app if present" `
        -FilePath $adb `
        -Arguments @("-s", $DeviceId, "uninstall", $appId) `
        -AllowFailure
    $log.Add("ADB uninstall app:")
    $log.AddRange([string[]]$uninstallOutput)
    $log.Add("")

    $installOutput = Invoke-LoggedCommand `
        -Title "Install APK" `
        -FilePath $adb `
        -Arguments @("-s", $DeviceId, "install", "-r", $apkPath)
    $log.Add("ADB install:")
    $log.AddRange([string[]]$installOutput)
    $log.Add("")

    if (-not $maestro) {
        $message = @"
Maestro CLI is not installed.

Install it with:
.\Mobile_testing\install-maestro-free.ps1

Then open a new terminal and run:
.\Mobile_testing\run-mobile-testing.bat
"@
        Write-Output $message
        $log.Add($message)
        throw "Maestro CLI not found."
    }

    $env:MAESTRO_CLI_NO_ANALYTICS = "1"
    $env:MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED = "true"
    $env:ANDROID_SERIAL = $DeviceId

    $maestroOutput = Invoke-LoggedCommand `
        -Title "Run Maestro flow" `
        -FilePath $maestro `
        -Arguments @("test", $flowPath)
    $log.Add("Maestro:")
    $log.AddRange([string[]]$maestroOutput)
    $log.Add("")
    $log.Add("Result: PASS")

    Write-Output ""
    Write-Output "Maestro mobile testing passed."
} catch {
    $log.Add("")
    $log.Add("Result: FAIL")
    $log.Add("Error: $($_.Exception.Message)")
    throw
} finally {
    $log | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Write-Output ""
    Write-Output "Mobile testing report: $reportPath"
}
