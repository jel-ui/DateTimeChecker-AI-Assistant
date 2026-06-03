param(
    [switch]$OfflineSample,
    [switch]$Headless,
    [switch]$AutoClose
)

. (Join-Path $PSScriptRoot "gemini-common.ps1")

$root = Split-Path -Parent $PSScriptRoot
$reports = Join-Path $root "reports"
$chatJsonPath = Join-Path $reports "chat-generated-testcases.json"
$chatTsvPath = Join-Path $reports "chat-generated-testcases.tsv"
$failuresPath = Join-Path $reports "ai-selenium-failures.tsv"
New-Item -ItemType Directory -Force -Path $reports | Out-Null

function Get-ChatSchema {
    return @{
        type = "object"
        additionalProperties = $false
        properties = @{
            assistantReply = @{ type = "string" }
            intent = @{ type = "string"; enum = @("test_project", "explain", "unknown") }
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
                        expectedValid = @{ type = "boolean" }
                        reason = @{ type = "string" }
                    }
                    required = @("id", "title", "day", "month", "year", "expectedValid", "reason")
                }
            }
        }
        required = @("assistantReply", "intent", "testCases")
    }
}

function Get-OfflineChatSample {
    return [pscustomobject]@{
        assistantReply = "Tôi hiểu yêu cầu. Tôi đã sinh 10 testcase ngày-tháng-năm gồm dữ liệu hợp lệ, boundary value, invalid format, giá trị trống và quy tắc năm nhuận. Bây giờ tôi sẽ chuyển dữ liệu cho Selenium chạy trực tiếp trên giao diện."
        intent = "test_project"
        testCases = @(
            [pscustomobject]@{ id = "CHAT01"; title = "Normal valid date"; day = "30"; month = "5"; year = "2026"; expectedValid = $true; reason = "Ordinary valid date." },
            [pscustomobject]@{ id = "CHAT02"; title = "Leap day valid"; day = "29"; month = "2"; year = "2024"; expectedValid = $true; reason = "2024 is a leap year." },
            [pscustomobject]@{ id = "CHAT03"; title = "Non-leap day invalid"; day = "29"; month = "2"; year = "2025"; expectedValid = $false; reason = "2025 is not a leap year." },
            [pscustomobject]@{ id = "CHAT04"; title = "Century leap year"; day = "29"; month = "2"; year = "2000"; expectedValid = $true; reason = "Years divisible by 400 remain leap years." },
            [pscustomobject]@{ id = "CHAT05"; title = "Century non-leap"; day = "29"; month = "2"; year = "1900"; expectedValid = $false; reason = "1900 is divisible by 100 but not 400." },
            [pscustomobject]@{ id = "CHAT06"; title = "Month boundary"; day = "31"; month = "4"; year = "2026"; expectedValid = $false; reason = "April has only 30 days." },
            [pscustomobject]@{ id = "CHAT07"; title = "Month upper boundary"; day = "30"; month = "13"; year = "2026"; expectedValid = $false; reason = "Month must be between 1 and 12." },
            [pscustomobject]@{ id = "CHAT08"; title = "Blank input"; day = ""; month = "5"; year = "2026"; expectedValid = $false; reason = "Day is required." },
            [pscustomobject]@{ id = "CHAT09"; title = "Day lower boundary"; day = "0"; month = "5"; year = "2026"; expectedValid = $false; reason = "Day must be between 1 and 31." },
            [pscustomobject]@{ id = "CHAT10"; title = "Month format invalid"; day = "30"; month = "5.5"; year = "2026"; expectedValid = $false; reason = "Month must be an integer." }
        )
    }
}

function Export-ChatCases {
    param([object]$Response)
    $Response | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $chatJsonPath -Encoding UTF8
    "id`ttitle`tday`tmonth`tyear`texpectedValid`treason" | Set-Content -LiteralPath $chatTsvPath -Encoding UTF8
    foreach ($testCase in $Response.testCases) {
        $row = @(
            $testCase.id, $testCase.title, $testCase.day, $testCase.month, $testCase.year,
            $testCase.expectedValid, $testCase.reason
        ) | ForEach-Object { ConvertTo-SafeTsvCell $_ }
        ($row -join "`t") | Add-Content -LiteralPath $chatTsvPath -Encoding UTF8
    }
}

function Invoke-ChatAi {
    param([string]$UserMessage)
    $prompt = @"
You are an AI testing assistant for the DateTimeChecker-Java web project.
Reply in Vietnamese.
Understand the user's request. If the user asks to test, find bugs, validate, or fix the project:
- set intent to test_project
- explain that you will generate test data and pass it to Selenium
- generate exactly 10 diverse UI test cases
- each test case only has day, month, and year input fields
- cover valid input, boundary values, blank or invalid formats, leap day 29/02/2024, non-leap 29/02/2025, century rules for 2000 and 1900, and month length
Otherwise answer briefly and use an empty testCases array.

USER MESSAGE:
$UserMessage
"@
    if ($OfflineSample) {
        return Invoke-GeminiJson -Prompt $prompt -Schema (Get-ChatSchema) -SchemaName "datetime_testing_chat" -OfflineSample (Get-OfflineChatSample)
    }
    try {
        return Invoke-GeminiJson -Prompt $prompt -Schema (Get-ChatSchema) -SchemaName "datetime_testing_chat"
    } catch {
        Write-Host "Gemini đang quá tải hoặc tạm thời không khả dụng."
        Write-Host "Trợ lý sẽ dùng bộ 10 testcase mẫu offline để tiếp tục demo thay vì đóng chat."
        return Get-OfflineChatSample
    }
}

Write-Output "============================================================"
Write-Output " DATE TIME CHECKER - GEMINI AI TESTING ASSISTANT CHAT"
Write-Output "============================================================"
Write-Output "Nhập yêu cầu tự nhiên bằng tiếng Việt."
Write-Output "Lệnh: /help, /demo-self-heal, /exit"
Write-Output ""

while ($true) {
    $message = Read-Host "Bạn"
    if (-not $message) { continue }
    if ($message -eq "/exit") { break }
    if ($message -eq "/help") {
        Write-Output "Ví dụ: Vui lòng testing project này, tìm lỗi và đề xuất sửa nếu có."
        Write-Output "Dùng /demo-self-heal để trình diễn AI tìm và sửa controlled defect trong bản sao tạm."
        continue
    }
    if ($message -eq "/demo-self-heal") {
        & (Join-Path $PSScriptRoot "ai-self-healing-demo.ps1") -OfflineSample:$OfflineSample -Headless:$Headless -AutoApprove:$AutoClose
        continue
    }

    Write-Output ""
    Write-Output "Gemini đang phân tích yêu cầu..."
    $response = Invoke-ChatAi -UserMessage $message
    Write-Output ""
    Write-Output "Trợ lý AI: $($response.assistantReply)"

    if ($response.intent -ne "test_project") {
        Write-Output ""
        continue
    }
    if ($response.testCases.Count -lt 1) {
        Write-Output "Trợ lý AI chưa tạo testcase. Vui lòng nhập yêu cầu cụ thể hơn."
        continue
    }

    Export-ChatCases -Response $response
    Write-Output ""
    Write-Output "Trợ lý AI đã tạo $($response.testCases.Count) testcase:"
    foreach ($testCase in $response.testCases) {
        Write-Output "  $($testCase.id) - $($testCase.title) - expectedValid=$($testCase.expectedValid)"
    }
    Write-Output ""
    Write-Output "Đang chuyển dữ liệu AI sang Selenium WebDriver..."

    $global:DateTimeCheckerSeleniumExitCode = $null
    try {
        & (Join-Path $PSScriptRoot "ai-generated-test-demo.ps1") -CasesPath $chatTsvPath -Headless:$Headless -AutoClose:$AutoClose
    } catch {
        Write-Output "Trợ lý AI: Selenium chưa chạy thành công: $($_.Exception.Message)"
        Write-Output "Bạn có thể chạy lại lệnh sau khi đóng server cũ hoặc để script tự dùng port dự phòng."
        Write-Output ""
        continue
    }
    $seleniumExitCode = if ($null -ne $global:DateTimeCheckerSeleniumExitCode) { $global:DateTimeCheckerSeleniumExitCode } else { $LASTEXITCODE }
    if ($seleniumExitCode -ne 0) {
        Write-Output "Trợ lý AI: Selenium chưa chạy thành công. Nếu lỗi là msedgedriver, hãy kết nối mạng hoặc chạy lại demo để Selenium Manager tải EdgeDriver."
        continue
    }

    if (-not (Test-Path -LiteralPath $failuresPath)) {
        Write-Output "Trợ lý AI: Không tìm thấy Selenium report."
        continue
    }
    $failures = @(Get-Content -LiteralPath $failuresPath | Select-Object -Skip 1)
    Write-Output ""
    if ($failures.Count -eq 0) {
        Write-Output "Trợ lý AI: Selenium đã chạy xong. Chưa phát hiện lỗi với bộ dữ liệu vừa sinh."
    } else {
        Write-Output "Trợ lý AI: Selenium phát hiện $($failures.Count) lỗi:"
        $failures | ForEach-Object { Write-Output "  $_" }
        Write-Output "Dùng lệnh /demo-self-heal để xem quy trình AI phân tích và sửa lỗi trong bản sao tạm."
    }
    Write-Output ""
}

Write-Output "Đã đóng Gemini AI Testing Assistant Chat."
