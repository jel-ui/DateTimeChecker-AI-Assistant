$ErrorActionPreference = "Stop"
try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [Console]::InputEncoding = $utf8NoBom
    [Console]::OutputEncoding = $utf8NoBom
    $OutputEncoding = $utf8NoBom
} catch {
}

$script:GeminiUnsavedSecureKey = $null

function Get-GeminiSecretPath {
    $root = Split-Path -Parent $PSScriptRoot
    return Join-Path $root ".secrets\gemini-api-key.txt"
}

function ConvertFrom-SecureValue {
    param(
        [Parameter(Mandatory = $true)]
        [Security.SecureString]$SecureValue
    )

    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
}

function Import-SavedGeminiKey {
    $secretPath = Get-GeminiSecretPath
    if (-not (Test-Path -LiteralPath $secretPath)) {
        return $false
    }

    try {
        $encryptedKey = (Get-Content -LiteralPath $secretPath -Raw).Trim()
        $secureKey = ConvertTo-SecureString $encryptedKey
        $env:GEMINI_API_KEY = ConvertFrom-SecureValue -SecureValue $secureKey
    } catch {
        throw "Không thể đọc Gemini API key đã lưu. Chạy reset-gemini-key.bat rồi nhập lại key."
    }

    if (-not $env:GEMINI_API_KEY) {
        throw "Gemini API key đã lưu bị trống. Chạy reset-gemini-key.bat rồi nhập lại key."
    }

    Write-Output "Đã dùng Gemini API key mã hóa được lưu cục bộ."
    return $true
}

function Save-GeminiKey {
    param(
        [Parameter(Mandatory = $true)]
        [Security.SecureString]$SecureKey
    )

    $secretPath = Get-GeminiSecretPath
    $secretDirectory = Split-Path -Parent $secretPath
    New-Item -ItemType Directory -Force -Path $secretDirectory | Out-Null
    $SecureKey | ConvertFrom-SecureString | Set-Content -LiteralPath $secretPath -Encoding ASCII
    Write-Output "Đã lưu key dạng mã hóa cục bộ. Key này không được đưa lên Git."
}

function Get-GeminiModel {
    if ($env:GEMINI_MODEL) {
        return $env:GEMINI_MODEL
    }

    return "gemini-2.5-flash"
}

function Request-GeminiKeyIfMissing {
    if ($env:GEMINI_API_KEY) {
        return
    }

    if (Import-SavedGeminiKey) {
        return
    }

    if (-not [Environment]::UserInteractive) {
        throw "Thiếu GEMINI_API_KEY."
    }

    Write-Output ""
    Write-Output "Nhập Gemini API key để chạy AI thật."
    Write-Output "Key sẽ được mã hóa bằng tài khoản Windows hiện tại và lưu cục bộ trong thư mục .secrets."
    Write-Output "File key đã được loại trừ khỏi Git. Dùng reset-gemini-key.bat nếu cần đổi key."
    $secureKey = Read-Host "GEMINI_API_KEY" -AsSecureString
    $env:GEMINI_API_KEY = ConvertFrom-SecureValue -SecureValue $secureKey

    if (-not $env:GEMINI_API_KEY) {
        throw "GEMINI_API_KEY không được để trống."
    }

    $script:GeminiUnsavedSecureKey = $secureKey
}

function Get-GeminiApiErrorMessage {
    param(
        [Parameter(Mandatory = $true)]
        [Management.Automation.ErrorRecord]$ErrorRecord
    )

    $details = $ErrorRecord.ErrorDetails.Message
    if (-not $details -and $ErrorRecord.Exception.Response) {
        try {
            $stream = $ErrorRecord.Exception.Response.GetResponseStream()
            $reader = New-Object IO.StreamReader($stream)
            try {
                $details = $reader.ReadToEnd()
            } finally {
                $reader.Dispose()
                $stream.Dispose()
            }
        } catch {
            $details = $null
        }
    }

    $apiMessage = $null
    $apiStatus = $null
    if ($details) {
        try {
            $parsed = $details | ConvertFrom-Json
            $apiMessage = $parsed.error.message
            $apiStatus = $parsed.error.status
        } catch {
            $apiMessage = $details
        }
    }

    if (-not $apiMessage) {
        $apiMessage = $ErrorRecord.Exception.Message
    }

    $combined = "$apiStatus $apiMessage"
    if ($combined -match "API_KEY_INVALID|API key not valid|API key was reported as leaked|PERMISSION_DENIED") {
        return "$apiMessage`nGemini API key không hợp lệ hoặc đã bị chặn. Chạy reset-gemini-key.bat rồi tạo hoặc nhập key khác từ Google AI Studio."
    }
    if ($combined -match "RESOURCE_EXHAUSTED|quota|429") {
        return "$apiMessage`nGemini API đã hết quota hoặc vượt giới hạn tạm thời. Chờ quota reset hoặc dùng key thuộc project Gemini khác."
    }
    if ($combined -match "FAILED_PRECONDITION|free tier is not available") {
        return "$apiMessage`nGemini free tier không khả dụng cho project hoặc khu vực hiện tại. Kiểm tra key trong Google AI Studio."
    }

    return "$apiMessage`nNếu lỗi liên quan API key, chạy reset-gemini-key.bat rồi nhập lại key."
}

function Invoke-GeminiJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,

        [Parameter(Mandatory = $true)]
        [hashtable]$Schema,

        [Parameter(Mandatory = $true)]
        [string]$SchemaName,

        [Parameter(Mandatory = $false)]
        [object]$OfflineSample
    )

    if ($null -ne $OfflineSample) {
        return $OfflineSample
    }

    Request-GeminiKeyIfMissing
    $model = Get-GeminiModel
    Write-Output "Calling Gemini API with model: $model"

    $payload = @{
        systemInstruction = @{
            parts = @(
                @{
                    text = "You are a software testing assistant. Return only the requested structured output. Follow the schema exactly."
                }
            )
        }
        contents = @(
            @{
                role = "user"
                parts = @(
                    @{
                        text = $Prompt
                    }
                )
            }
        )
        generationConfig = @{
            responseMimeType = "application/json"
            responseJsonSchema = $Schema
        }
    } | ConvertTo-Json -Depth 100

    $headers = @{
        "x-goog-api-key" = $env:GEMINI_API_KEY
        "Content-Type" = "application/json"
    }
    $uri = "https://generativelanguage.googleapis.com/v1beta/models/$model`:generateContent"
    try {
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $payload
    } catch {
        throw "Gemini API error: $(Get-GeminiApiErrorMessage -ErrorRecord $_)"
    }

    $text = $response.candidates[0].content.parts[0].text
    if (-not $text) {
        throw "Gemini API không trả về JSON text."
    }

    $parsedResponse = $text | ConvertFrom-Json
    if ($script:GeminiUnsavedSecureKey) {
        Save-GeminiKey -SecureKey $script:GeminiUnsavedSecureKey
        $script:GeminiUnsavedSecureKey = $null
    }

    return $parsedResponse
}

function ConvertTo-SafeTsvCell {
    param([object]$Value)
    if ($null -eq $Value) {
        return ""
    }
    return ([string]$Value).Replace("`t", " ").Replace("`r", " ").Replace("`n", " ")
}
