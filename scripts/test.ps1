. (Join-Path $PSScriptRoot "common.ps1")

$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot "build.ps1")
$tools = Get-JavaTools
$classes = Join-Path $root "out\classes"
$testClasses = Join-Path $root "out\test-classes"
Assert-SafeChildPath -Root $root -Path $testClasses

if (Test-Path -LiteralPath $testClasses) {
    Remove-Item -LiteralPath $testClasses -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $testClasses | Out-Null

$testSources = Get-ChildItem -LiteralPath (Join-Path $root "src\test\java") -Recurse -Filter "*.java" |
    ForEach-Object { $_.FullName.Substring($root.Length + 1) }
$previousLocation = Get-Location

try {
    Set-Location -LiteralPath $root
    & $tools.Javac -encoding UTF-8 -cp "out\classes" -d "out\test-classes" $testSources
    if ($LASTEXITCODE -ne 0) {
        throw "Biên dịch test Java thất bại."
    }
} finally {
    Set-Location -LiteralPath $previousLocation
}

try {
    Set-Location -LiteralPath $root
    & $tools.Java -cp "out\classes;out\test-classes" com.datetimechecker.DateTimeValidationServiceTest
    if ($LASTEXITCODE -ne 0) {
        throw "Test Java thất bại."
    }
} finally {
    Set-Location -LiteralPath $previousLocation
}
