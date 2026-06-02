param(
    [switch]$OfflineSample,
    [switch]$Headless,
    [switch]$AutoApprove
)

. (Join-Path $PSScriptRoot "common.ps1")
. (Join-Path $PSScriptRoot "gemini-common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$lab = Join-Path $root "out\ai-self-heal-lab"
$labSourceRoot = Join-Path $lab "src\main\java"
$labClasses = Join-Path $lab "classes"
$reports = Join-Path $root "reports"
$failuresPath = Join-Path $reports "ai-selenium-failures.tsv"
$beforeFailuresPath = Join-Path $reports "ai-selenium-failures-before-fix.tsv"
$afterFailuresPath = Join-Path $reports "ai-selenium-failures-after-fix.tsv"
$analysisPath = Join-Path $reports "ai-fix-analysis.json"
$suggestedFixPath = Join-Path $reports "ai-fix-suggested-DateTimeValidationService.java"
$productionSource = Join-Path $root "src\main\java\com\datetimechecker\DateTimeValidationService.java"
$labSource = Join-Path $labSourceRoot "com\datetimechecker\DateTimeValidationService.java"
$seleniumClasses = Join-Path $root "out\ai-selenium-classes"
$serverProcess = $null
$demoUrl = "http://localhost:4174"
$lastSeleniumExit = 0

function Test-DateTimeCheckerServer {
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "$demoUrl/" -TimeoutSec 2
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

function Stop-LabServer {
    if ($script:serverProcess -and -not $script:serverProcess.HasExited) {
        Stop-Process -Id $script:serverProcess.Id -Force
        Start-Sleep -Milliseconds 500
    }
    $script:serverProcess = $null
}

function Start-LabServer {
    param([string]$JavaPath)
    if (Test-DateTimeCheckerServer) {
        throw "Port 4174 đang được dùng. Hãy đóng tiến trình demo cũ trước khi chạy lại."
    }
    $script:serverProcess = Start-Process -FilePath $JavaPath `
        -ArgumentList "-Ddatetimechecker.port=4174", "-cp", "out\ai-self-heal-lab\classes", "com.datetimechecker.App" `
        -WorkingDirectory $root `
        -WindowStyle Hidden `
        -PassThru
    for ($attempt = 0; $attempt -lt 40; $attempt++) {
        if (Test-DateTimeCheckerServer) { return }
        Start-Sleep -Milliseconds 250
    }
    throw "Không thể khởi động localhost cho bản sao self-healing."
}

function Compile-Lab {
    param([string]$CompilerPath)
    if (Test-Path -LiteralPath $labClasses) {
        Remove-Item -LiteralPath $labClasses -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $labClasses | Out-Null
    $sources = Get-ChildItem -LiteralPath $labSourceRoot -Recurse -Filter "*.java" |
        ForEach-Object { $_.FullName.Substring($lab.Length + 1) }
    $previous = Get-Location
    try {
        Set-Location -LiteralPath $lab
        & $CompilerPath -encoding UTF-8 -d "classes" $sources
        if ($LASTEXITCODE -ne 0) { throw "Biên dịch bản sao self-healing thất bại." }
    } finally {
        Set-Location -LiteralPath $previous
    }
}

function Compile-AiSeleniumRunner {
    param([string]$CompilerPath)
    New-Item -ItemType Directory -Force -Path $seleniumClasses | Out-Null
    $previous = Get-Location
    try {
        Set-Location -LiteralPath $root
        & $CompilerPath -encoding UTF-8 -cp "tools\selenium-server-4.44.0.jar" -d "out\ai-selenium-classes" `
            "src\selenium\java\com\datetimechecker\AiGeneratedSeleniumDemo.java"
        if ($LASTEXITCODE -ne 0) { throw "Biên dịch AI Selenium runner thất bại." }
    } finally {
        Set-Location -LiteralPath $previous
    }
}

function Invoke-AiSelenium {
    param(
        [string]$JavaPath,
        [string]$CasesPath
    )
    $relativeCases = $CasesPath.Substring($root.Length + 1)
    $arguments = @("-Ddatetimechecker.url=$demoUrl", "-cp", "tools\selenium-server-4.44.0.jar;out\ai-selenium-classes", "com.datetimechecker.AiGeneratedSeleniumDemo", "--cases", $relativeCases, "--auto-close")
    if ($Headless) { $arguments += "--headless" }
    $previous = Get-Location
    try {
        Set-Location -LiteralPath $root
        & $JavaPath $arguments
        $script:lastSeleniumExit = $LASTEXITCODE
    } finally {
        Set-Location -LiteralPath $previous
    }
}

$fixSchema = @{
    type = "object"
    additionalProperties = $false
    properties = @{
        diagnosis = @{ type = "string" }
        explanation = @{ type = "string" }
        fixedSource = @{ type = "string" }
    }
    required = @("diagnosis", "explanation", "fixedSource")
}

Write-Output "============================================================"
Write-Output " AI SELF-HEALING DEMO - ISOLATED TEMPORARY COPY"
Write-Output "============================================================"
Write-Output "Production source will NOT be modified."
Write-Output "The controlled defect and AI fix exist only under out\ai-self-heal-lab."
Write-Output ""

if (Test-DateTimeCheckerServer) {
    throw "Port 4174 đang được dùng. Hãy đóng tiến trình demo cũ trước khi chạy lại."
}

$testCaseTsv = Join-Path $root "reports\ai-generated-testcases.tsv"
if ($OfflineSample) {
    & (Join-Path $PSScriptRoot "ai-generate-testcases.ps1") -OfflineSample
} else {
    & (Join-Path $PSScriptRoot "ai-generate-testcases.ps1")
}

& (Join-Path $PSScriptRoot "build.ps1")
$appTools = Get-JavaTools
$newTools = Get-NewJavaTools
New-Item -ItemType Directory -Force -Path $reports | Out-Null
if (Test-Path -LiteralPath $lab) {
    Remove-Item -LiteralPath $lab -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $labSourceRoot | Out-Null
Get-ChildItem -Force -LiteralPath (Join-Path $root "src\main\java") |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $labSourceRoot -Recurse -Force }

$originalSource = [IO.File]::ReadAllText($productionSource)
$mutantSource = $originalSource.Replace(
    "Month.of(month).length(java.time.Year.isLeap(year))",
    "Month.of(month).length(false)")
if ($mutantSource -eq $originalSource) {
    throw "Không thể tạo controlled defect."
}
[IO.File]::WriteAllText($labSource, $mutantSource, [Text.UTF8Encoding]::new($false))
Write-Output "Injected controlled defect into temporary copy: leap-year calculation forced to false."

Compile-Lab -CompilerPath $appTools.Javac
Compile-AiSeleniumRunner -CompilerPath $newTools.Javac

try {
    Start-LabServer -JavaPath $appTools.Java
    Write-Output ""
    Write-Output "STEP 1: Selenium executes AI-generated cases against the buggy temporary copy."
    Invoke-AiSelenium -JavaPath $newTools.Java -CasesPath $testCaseTsv
    $beforeExit = $script:lastSeleniumExit
} finally {
    Stop-LabServer
}

if ($beforeExit -eq 0) {
    throw "Controlled defect was not detected. Self-healing demo stopped."
}

$failures = Get-Content -LiteralPath $failuresPath -Raw
Copy-Item -LiteralPath $failuresPath -Destination $beforeFailuresPath -Force
Write-Output ""
Write-Output "STEP 2: Gemini analyzes failing Selenium cases and proposes a source-code fix."
$fixPrompt = @"
Analyze the Java source and Selenium failure report below.
Return a corrected full Java source file for DateTimeValidationService.java.
Fix only the root cause. Preserve package, public API, Vietnamese messages, and unrelated behavior.

SELENIUM FAILURE REPORT:
$failures

JAVA SOURCE WITH CONTROLLED DEFECT:
$mutantSource
"@
$offlineFix = [pscustomobject]@{
    diagnosis = "The leap-year flag was forced to false when calculating the number of days in a month."
    explanation = "Restore java.time.Year.isLeap(year) so February has 29 days in valid leap years such as 2024 and 2000."
    fixedSource = $originalSource
}
$fix = if ($OfflineSample) {
    Invoke-GeminiJson -Prompt $fixPrompt -Schema $fixSchema -SchemaName "datetime_java_fix" -OfflineSample $offlineFix
} else {
    Invoke-GeminiJson -Prompt $fixPrompt -Schema $fixSchema -SchemaName "datetime_java_fix"
}
$fix | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $analysisPath -Encoding UTF8
[IO.File]::WriteAllText($suggestedFixPath, [string]$fix.fixedSource, [Text.UTF8Encoding]::new($false))

Write-Output ""
Write-Output "GEMINI DIAGNOSIS: $($fix.diagnosis)"
Write-Output "GEMINI EXPLANATION: $($fix.explanation)"
Write-Output "Suggested fix file: $suggestedFixPath"
Write-Output ""

$apply = $AutoApprove
if (-not $AutoApprove) {
    $answer = Read-Host "Apply AI fix to the TEMPORARY COPY and rerun Selenium? (Y/N)"
    $apply = $answer -match "^(y|yes)$"
}
if (-not $apply) {
    Write-Output "AI fix was not applied. Production source remains unchanged."
    exit 0
}

Write-Output ""
Write-Output "STEP 3: Apply AI fix only to temporary copy, rebuild, and rerun Selenium regression."
[IO.File]::WriteAllText($labSource, [string]$fix.fixedSource, [Text.UTF8Encoding]::new($false))
Compile-Lab -CompilerPath $appTools.Javac
try {
    Start-LabServer -JavaPath $appTools.Java
    Invoke-AiSelenium -JavaPath $newTools.Java -CasesPath $testCaseTsv
    $afterExit = $script:lastSeleniumExit
} finally {
    Stop-LabServer
}

if ($afterExit -ne 0) {
    throw "AI fix did not pass Selenium regression tests."
}
Copy-Item -LiteralPath $failuresPath -Destination $afterFailuresPath -Force

Write-Output ""
Write-Output "SELF-HEALING DEMO PASSED."
Write-Output "AI-generated tests detected the bug, AI proposed a fix, and Selenium regression passed."
Write-Output "Production source remained unchanged."
Write-Output "Before-fix report: $beforeFailuresPath"
Write-Output "After-fix report: $afterFailuresPath"
