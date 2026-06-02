$ErrorActionPreference = "Stop"

function Get-JavaTools {
    $candidates = @()

    if ($env:JAVA_HOME) {
        $candidates += (Join-Path $env:JAVA_HOME "bin\javac.exe")
    }

    $compilerCommand = Get-Command "javac.exe" -ErrorAction SilentlyContinue
    if ($compilerCommand) {
        $candidates += $compilerCommand.Source
    }

    $candidates += "C:\Program Files\Java\jdk1.8.0_172\bin\javac.exe"

    if (Test-Path -LiteralPath "C:\Program Files\Java") {
        $candidates += Get-ChildItem -LiteralPath "C:\Program Files\Java" -Recurse -Filter "javac.exe" -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName
    }

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

    throw "Không tìm thấy JDK. Vui lòng cài JDK 8 trở lên."
}

function Assert-SafeChildPath {
    param(
        [string]$Root,
        [string]$Path
    )

    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd("\")
    $childPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $childPath.StartsWith($rootPath + "\", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Đường dẫn không an toàn: $childPath"
    }
}
