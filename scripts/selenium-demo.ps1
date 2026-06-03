param(
    [switch]$Headless,
    [switch]$AutoClose
)

. (Join-Path $PSScriptRoot "common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$jar = Join-Path $root "tools\selenium-server-4.44.0.jar"
$seleniumClasses = Join-Path $root "out\selenium-classes"
$serverProcess = $null
$serverWasStarted = $false

function Get-SeleniumJavaTools {
    $candidates = @(
        "C:\Program Files\JetBrains\JetBrains Rider 2026.1.1\jbr\bin\javac.exe"
    )

    if (Test-Path -LiteralPath "C:\Program Files\JetBrains") {
        $candidates += Get-ChildItem -LiteralPath "C:\Program Files\JetBrains" -Recurse -Filter "javac.exe" -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName
    }

    foreach ($compiler in $candidates | Select-Object -Unique) {
        if (-not (Test-Path -LiteralPath $compiler)) {
            continue
        }

        $java = Join-Path (Split-Path -Parent $compiler) "java.exe"
        if (Test-Path -LiteralPath $java) {
            return @{
                Javac = $compiler
                Java = $java
            }
        }
    }

    throw "Không tìm thấy JDK mới để chạy Selenium. Vui lòng cài JDK 17 trở lên."
}

if (-not (Test-Path -LiteralPath $jar)) {
    throw "Không tìm thấy tools\selenium-server-4.44.0.jar."
}

& (Join-Path $PSScriptRoot "build.ps1")
$appTools = Get-JavaTools
$seleniumTools = Get-SeleniumJavaTools
Assert-SafeChildPath -Root $root -Path $seleniumClasses

if (Test-Path -LiteralPath $seleniumClasses) {
    Remove-Item -LiteralPath $seleniumClasses -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $seleniumClasses | Out-Null

$previousLocation = Get-Location
try {
    Set-Location -LiteralPath $root
    & $seleniumTools.Javac -encoding UTF-8 -cp "tools\selenium-server-4.44.0.jar" -d "out\selenium-classes" `
        "src\selenium\java\com\datetimechecker\SeleniumVisibleDemo.java"
    if ($LASTEXITCODE -ne 0) {
        throw "Biên dịch Selenium demo thất bại."
    }

    $server = Start-DateTimeCheckerServerForDemo -Java $appTools.Java -Classes "out\classes" -Root $root
    $serverProcess = $server.Process
    $serverWasStarted = $server.Started

    Write-Output ""
    Write-Output "============================================================"
    Write-Output " SELENIUM VISIBLE UI TEST DEMO"
    Write-Output "============================================================"
    Write-Output "Edge sẽ tự mở và thao tác từng testcase."
    Write-Output "Selenium target: $($server.Url)"
    Write-Output "Theo dõi cửa sổ Edge và popup testcase ở giữa màn hình."
    Write-Output ""

    $arguments = @("-Dfile.encoding=UTF-8", "-Dsun.stdout.encoding=UTF-8", "-Dsun.stderr.encoding=UTF-8", "-Ddatetimechecker.url=$($server.Url)", "-cp", "tools\selenium-server-4.44.0.jar;out\selenium-classes", "com.datetimechecker.SeleniumVisibleDemo")
    if ($Headless) {
        $arguments += "--headless"
    }
    if ($AutoClose) {
        $arguments += "--auto-close"
    }

    & $seleniumTools.Java $arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Selenium UI demo thất bại."
    }
} finally {
    if ($serverWasStarted -and $serverProcess -and -not $serverProcess.HasExited) {
        Stop-Process -Id $serverProcess.Id -Force
    }
    Set-Location -LiteralPath $previousLocation
}
