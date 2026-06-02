. (Join-Path $PSScriptRoot "common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$classes = Join-Path $root "out\classes"
Assert-SafeChildPath -Root $root -Path $classes

if (Test-Path -LiteralPath $classes) {
    Remove-Item -LiteralPath $classes -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $classes | Out-Null

$tools = Get-JavaTools
$sources = Get-ChildItem -LiteralPath (Join-Path $root "src\main\java") -Recurse -Filter "*.java" |
    ForEach-Object { $_.FullName.Substring($root.Length + 1) }
$previousLocation = Get-Location

try {
    Set-Location -LiteralPath $root
    & $tools.Javac -encoding UTF-8 -d "out\classes" $sources
    if ($LASTEXITCODE -ne 0) {
        throw "Biên dịch Java thất bại."
    }
} finally {
    Set-Location -LiteralPath $previousLocation
}

Write-Output "Build Java thành công."
