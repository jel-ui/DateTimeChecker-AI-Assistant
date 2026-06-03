. (Join-Path $PSScriptRoot "..\scripts\common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$reportPath = Join-Path $root "reports\api-testing-report.tsv"

& (Join-Path $root "scripts\build.ps1")
$tools = Get-JavaTools
$classes = Join-Path $root "out\classes"
$server = Start-DateTimeCheckerServerForDemo -Java $tools.Java -Classes $classes -Root $root

$testCases = @(
    @{ Id = "API01"; Name = "Valid date"; Day = "30"; Month = "5"; Year = "2026"; ExpectedValid = $true },
    @{ Id = "API02"; Name = "Invalid day in month"; Day = "31"; Month = "4"; Year = "2026"; ExpectedValid = $false },
    @{ Id = "API03"; Name = "Leap year valid"; Day = "29"; Month = "2"; Year = "2024"; ExpectedValid = $true },
    @{ Id = "API04"; Name = "Non-leap year invalid"; Day = "29"; Month = "2"; Year = "2025"; ExpectedValid = $false },
    @{ Id = "API05"; Name = "Day below range"; Day = "0"; Month = "5"; Year = "2026"; ExpectedValid = $false },
    @{ Id = "API06"; Name = "Month above range"; Day = "30"; Month = "13"; Year = "2026"; ExpectedValid = $false },
    @{ Id = "API07"; Name = "Year below range"; Day = "30"; Month = "5"; Year = "999"; ExpectedValid = $false },
    @{ Id = "API08"; Name = "Year above range"; Day = "30"; Month = "5"; Year = "3001"; ExpectedValid = $false },
    @{ Id = "API09"; Name = "Day is not a number"; Day = "abc"; Month = "5"; Year = "2026"; ExpectedValid = $false },
    @{ Id = "API10"; Name = "Month is decimal"; Day = "30"; Month = "5.5"; Year = "2026"; ExpectedValid = $false }
)

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("id`tname`tinput`texpected_valid`tactual_valid`tstatus_code`telapsed_ms`tresult")
$failures = New-Object System.Collections.Generic.List[string]

try {
    foreach ($testCase in $testCases) {
        $body = @{
            day = $testCase.Day
            month = $testCase.Month
            year = $testCase.Year
        } | ConvertTo-Json

        $elapsed = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Method Post `
            -Uri "$($server.Url)/api/datetime/check" `
            -ContentType "application/json; charset=utf-8" `
            -Body $body `
            -UseBasicParsing `
            -TimeoutSec 5
        $elapsed.Stop()

        $json = $response.Content | ConvertFrom-Json
        $passed = ($response.StatusCode -eq 200) -and ($json.valid -eq $testCase.ExpectedValid) -and ($elapsed.ElapsedMilliseconds -le 1000)
        $result = if ($passed) { "PASS" } else { "FAIL" }
        $input = "$($testCase.Day)/$($testCase.Month)/$($testCase.Year)"

        Write-Output "$($testCase.Id) $result - $($testCase.Name) - $input - $($elapsed.ElapsedMilliseconds) ms"
        $rows.Add("$($testCase.Id)`t$($testCase.Name)`t$input`t$($testCase.ExpectedValid)`t$($json.valid)`t$($response.StatusCode)`t$($elapsed.ElapsedMilliseconds)`t$result")

        if (-not $passed) {
            $failures.Add($testCase.Id)
        }
    }

    $rows | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Write-Output ""
    Write-Output "API testing report: $reportPath"

    if ($failures.Count -gt 0) {
        throw "$($failures.Count) API test(s) failed: $($failures -join ', ')"
    }

    Write-Output "All $($testCases.Count) API tests passed."
} finally {
    if ($server.Started -and $server.Process -and -not $server.Process.HasExited) {
        Stop-Process -Id $server.Process.Id -Force
    }
}
