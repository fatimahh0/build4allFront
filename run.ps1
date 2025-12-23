param(
  [string]$EnvFile = "lib/env/ecommerce_dev.json"
)

$ErrorActionPreference = "Stop"

Write-Host "==> Step 1: Apply branding from $EnvFile"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\tool\apply_env_branding.ps1" -EnvFile $EnvFile
if ($LASTEXITCODE -ne 0) { throw "apply_env_branding.ps1 failed (exit $LASTEXITCODE)" }

Write-Host "==> Step 2: Detect Android device (machine output)"
$devicesJson = flutter devices --machine | Out-String
$devices = $devicesJson | ConvertFrom-Json

$android = $devices | Where-Object { $_.targetPlatform -like "android*" } | Select-Object -First 1
if ($null -eq $android) {
  Write-Host "❌ No Android device detected. Make sure USB debugging is ON and run: adb devices" -ForegroundColor Red
  exit 1
}

$deviceId = $android.id
Write-Host "✅ Using Android device: $($android.name) | id=$deviceId"

Write-Host "==> Step 3: Run on detected Android device"
flutter run -d $deviceId --dart-define-from-file=$EnvFile
