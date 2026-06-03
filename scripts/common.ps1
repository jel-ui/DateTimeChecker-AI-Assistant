$ErrorActionPreference = "Stop"

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [Console]::InputEncoding = $utf8NoBom
    [Console]::OutputEncoding = $utf8NoBom
    $OutputEncoding = $utf8NoBom
} catch {
}

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

function Test-DateTimeCheckerAppServer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "$Url/" -TimeoutSec 2
        if (-not ($response.StatusCode -eq 200 `
            -and $response.Content.Contains("<title>Date Time Checker</title>") `
            -and $response.Content.Contains("Dùng hôm nay") `
            -and -not $response.Content.Contains('id="hour"'))) {
            return $false
        }

        $apiBody = @{ day = "15"; month = "6"; year = "2023" } | ConvertTo-Json
        $apiResponse = Invoke-RestMethod -Method Post -Uri "$Url/api/datetime/check" `
            -ContentType "application/json; charset=utf-8" `
            -Body $apiBody `
            -TimeoutSec 2
        return $apiResponse.valid -eq $true
    } catch {
        return $false
    }
}

function Test-TcpPortAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Port
    )

    $listener = $null
    try {
        $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
        $listener.Start()
        return $true
    } catch {
        return $false
    } finally {
        if ($listener) {
            $listener.Stop()
        }
    }
}

function Start-DateTimeCheckerServerForDemo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Java,

        [Parameter(Mandatory = $true)]
        [string]$Classes,

        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $defaultUrl = "http://localhost:4173"
    if (Test-DateTimeCheckerAppServer -Url $defaultUrl) {
        return [pscustomobject]@{
            Url = $defaultUrl
            Process = $null
            Started = $false
        }
    }

    for ($port = 4174; $port -le 4190; $port++) {
        $url = "http://localhost:$port"
        if (Test-DateTimeCheckerAppServer -Url $url) {
            return [pscustomobject]@{
                Url = $url
                Process = $null
                Started = $false
            }
        }

        if (-not (Test-TcpPortAvailable -Port $port)) {
            continue
        }

        $process = Start-Process -FilePath $Java `
            -ArgumentList "-Ddatetimechecker.port=$port", "-cp", $Classes, "com.datetimechecker.App" `
            -WorkingDirectory $Root `
            -WindowStyle Hidden `
            -PassThru

        for ($attempt = 0; $attempt -lt 40; $attempt++) {
            if (Test-DateTimeCheckerAppServer -Url $url) {
                return [pscustomobject]@{
                    Url = $url
                    Process = $process
                    Started = $true
                }
            }
            if ($process.HasExited) {
                break
            }
            Start-Sleep -Milliseconds 250
        }

        if (-not $process.HasExited) {
            Stop-Process -Id $process.Id -Force
        }
    }

    throw "Không thể khởi động Date Time Checker trên port 4173 hoặc port dự phòng 4174-4190."
}
