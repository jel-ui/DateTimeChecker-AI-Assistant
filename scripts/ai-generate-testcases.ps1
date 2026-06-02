param(
    [switch]$OfflineSample
)

. (Join-Path $PSScriptRoot "gemini-common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$reports = Join-Path $root "reports"
$jsonPath = Join-Path $reports "ai-generated-testcases.json"
$tsvPath = Join-Path $reports "ai-generated-testcases.tsv"
New-Item -ItemType Directory -Force -Path $reports | Out-Null

$testCaseSchema = @{
    type = "object"
    additionalProperties = $false
    properties = @{
        summary = @{ type = "string" }
        testCases = @{
            type = "array"
            items = @{
                type = "object"
                additionalProperties = $false
                properties = @{
                    id = @{ type = "string" }
                    title = @{ type = "string" }
                    day = @{ type = "string" }
                    month = @{ type = "string" }
                    year = @{ type = "string" }
                    hour = @{ type = "string" }
                    minute = @{ type = "string" }
                    second = @{ type = "string" }
                    expectedValid = @{ type = "boolean" }
                    reason = @{ type = "string" }
                }
                required = @("id", "title", "day", "month", "year", "hour", "minute", "second", "expectedValid", "reason")
            }
        }
    }
    required = @("summary", "testCases")
}

$sample = [pscustomobject]@{
    summary = "Offline sample used only to verify the local pipeline without an API key."
    testCases = @(
        [pscustomobject]@{ id = "AI01"; title = "Normal valid date"; day = "30"; month = "5"; year = "2026"; hour = "14"; minute = "20"; second = "10"; expectedValid = $true; reason = "Ordinary valid date and time." },
        [pscustomobject]@{ id = "AI02"; title = "Leap day valid"; day = "29"; month = "2"; year = "2024"; hour = "14"; minute = "20"; second = "10"; expectedValid = $true; reason = "2024 is divisible by 4 and is a leap year." },
        [pscustomobject]@{ id = "AI03"; title = "Non-leap day invalid"; day = "29"; month = "2"; year = "2025"; hour = "14"; minute = "20"; second = "10"; expectedValid = $false; reason = "2025 is not a leap year." },
        [pscustomobject]@{ id = "AI04"; title = "Century leap year valid"; day = "29"; month = "2"; year = "2000"; hour = "23"; minute = "59"; second = "59"; expectedValid = $true; reason = "Years divisible by 400 remain leap years." },
        [pscustomobject]@{ id = "AI05"; title = "Century non-leap invalid"; day = "29"; month = "2"; year = "1900"; hour = "0"; minute = "0"; second = "0"; expectedValid = $false; reason = "Years divisible by 100 but not 400 are not leap years." },
        [pscustomobject]@{ id = "AI06"; title = "April day boundary invalid"; day = "31"; month = "4"; year = "2026"; hour = "12"; minute = "0"; second = "0"; expectedValid = $false; reason = "April has only 30 days." },
        [pscustomobject]@{ id = "AI07"; title = "Hour upper boundary invalid"; day = "30"; month = "5"; year = "2026"; hour = "24"; minute = "0"; second = "0"; expectedValid = $false; reason = "Hour must be between 0 and 23." },
        [pscustomobject]@{ id = "AI08"; title = "Minute format invalid"; day = "30"; month = "5"; year = "2026"; hour = "14"; minute = "3.5"; second = "0"; expectedValid = $false; reason = "Minute must be an integer." }
    )
}

$prompt = @"
Generate exactly 10 diverse UI test cases as JSON for a Date Time Checker web application.
Each case must contain string input fields for day, month, year, hour, minute, and second, plus expectedValid and a concise reason.
Include normal cases, boundaries, invalid formats, blank input, leap day 29/02/2024, non-leap day 29/02/2025, century leap-year rule for 2000 and 1900, month length, and time ranges.
Use unique IDs starting with AI.
These cases will be executed by Selenium against a real web UI.
"@

$result = if ($OfflineSample) {
    Invoke-GeminiJson -Prompt $prompt -Schema $testCaseSchema -SchemaName "datetime_testcases" -OfflineSample $sample
} else {
    Invoke-GeminiJson -Prompt $prompt -Schema $testCaseSchema -SchemaName "datetime_testcases"
}

if ($result.testCases.Count -lt 8) {
    throw "AI tạo quá ít testcase: $($result.testCases.Count)."
}

$result | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
"id`ttitle`tday`tmonth`tyear`thour`tminute`tsecond`texpectedTitle`treason" | Set-Content -LiteralPath $tsvPath -Encoding UTF8
foreach ($testCase in $result.testCases) {
    $expectedTitle = if ($testCase.expectedValid) { "Ngày giờ hợp lệ" } else { "Ngày giờ không hợp lệ" }
    $row = @(
        $testCase.id,
        $testCase.title,
        $testCase.day,
        $testCase.month,
        $testCase.year,
        $testCase.hour,
        $testCase.minute,
        $testCase.second,
        $expectedTitle,
        $testCase.reason
    ) | ForEach-Object { ConvertTo-SafeTsvCell $_ }
    ($row -join "`t") | Add-Content -LiteralPath $tsvPath -Encoding UTF8
}

Write-Output ""
Write-Output "AI generated $($result.testCases.Count) test cases."
Write-Output "JSON report: $jsonPath"
Write-Output "Selenium input: $tsvPath"
Write-Output ""
foreach ($testCase in $result.testCases) {
    Write-Output "$($testCase.id) - $($testCase.title) - expectedValid=$($testCase.expectedValid)"
}

return $tsvPath
