param(
    [switch]$OfflineSample,
    [switch]$Headless,
    [switch]$AutoClose,
    [string]$CasesPath,
    [string]$AppClasses = "out\classes"
)

. (Join-Path $PSScriptRoot "common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$jar = Join-Path $root "tools\selenium-server-4.44.0.jar"
$seleniumClasses = Join-Path $root "out\ai-selenium-classes"
$serverProcess = $null
$serverWasStarted = $false

function Test-DateTimeCheckerServer {
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:4173/" -TimeoutSec 2
        return $response.StatusCode -eq 200 -and $response.Content.Contains("<title>Date Time Checker</title>")
    } catch {
        return $false
    }
}

function Get-NewJavaTools {
    $compiler = Get-ChildItem -LiteralPath "C:\Program Files\JetBrains" -Recurse -Filter "javac.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if (-not $compiler) {
        throw "Không tìm thấy JDK 17 trở lên để chạy Selenium."
    }
    return @{
        Javac = $compiler
        Java = Join-Path (Split-Path -Parent $compiler) "java.exe"
    }
}

Write-Output "============================================================"
Write-Output " AI-GENERATED TEST DATA + SELENIUM"
Write-Output "============================================================"
$testCaseTsv = if ($CasesPath) { $CasesPath } else { Join-Path $root "reports\ai-generated-testcases.tsv" }
if (-not $CasesPath) {
    if ($OfflineSample) {
        & (Join-Path $PSScriptRoot "ai-generate-testcases.ps1") -OfflineSample
    } else {
        & (Join-Path $PSScriptRoot "ai-generate-testcases.ps1")
    }
}

if (-not (Test-Path -LiteralPath $testCaseTsv)) {
    throw "Không tìm thấy file testcase do AI tạo: $testCaseTsv"
}

& (Join-Path $PSScriptRoot "build.ps1")
$appTools = Get-JavaTools
$newTools = Get-NewJavaTools
New-Item -ItemType Directory -Force -Path $seleniumClasses | Out-Null
$previousLocation = Get-Location
try {
    Set-Location -LiteralPath $root
    & $newTools.Javac -encoding UTF-8 -cp "tools\selenium-server-4.44.0.jar" -d "out\ai-selenium-classes" `
        "src\selenium\java\com\datetimechecker\AiGeneratedSeleniumDemo.java"
    if ($LASTEXITCODE -ne 0) { throw "Biên dịch AI Selenium runner thất bại." }

    if (-not (Test-DateTimeCheckerServer)) {
        $serverProcess = Start-Process -FilePath $appTools.Java -ArgumentList "-cp", $AppClasses, "com.datetimechecker.App" `
            -WorkingDirectory $root -WindowStyle Hidden -PassThru
        $serverWasStarted = $true
        for ($attempt = 0; $attempt -lt 40; $attempt++) {
            if (Test-DateTimeCheckerServer) { break }
            Start-Sleep -Milliseconds 250
        }
    }
    if (-not (Test-DateTimeCheckerServer)) { throw "Không thể khởi động localhost." }

    $arguments = @("-cp", "tools\selenium-server-4.44.0.jar;out\ai-selenium-classes", "com.datetimechecker.AiGeneratedSeleniumDemo", "--cases", $testCaseTsv)
    if ($Headless) { $arguments += "--headless" }
    if ($AutoClose) { $arguments += "--auto-close" }
    & $newTools.Java $arguments
    return $LASTEXITCODE
} finally {
    if ($serverWasStarted -and $serverProcess -and -not $serverProcess.HasExited) {
        Stop-Process -Id $serverProcess.Id -Force
    }
    Set-Location -LiteralPath $previousLocation
}
