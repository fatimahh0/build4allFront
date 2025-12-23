param(
  [string]$EnvFile = "lib/env/ecommerce_dev.json"
)

# ---------------- strict-ish behavior ----------------
$ErrorActionPreference = "Stop"

# ---------------- helpers ----------------
function Ensure-Dir($p) {
  if (!(Test-Path $p)) {
    New-Item -ItemType Directory -Path $p | Out-Null
  }
}

function Get-JsonPropValue($obj, $propName) {
  if ($null -eq $obj) { return $null }
  $names = $obj.PSObject.Properties.Name
  if ($names -contains $propName) { return $obj.$propName }
  return $null
}

function Run-Ok([string]$cmd) {
  Write-Host ">> $cmd"
  # Use call operator so errors propagate correctly
  & cmd.exe /c $cmd
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed (exit $LASTEXITCODE): $cmd"
  }
}

try {
  # ---------------- read json ----------------
  if (!(Test-Path $EnvFile)) { throw "Env file not found: $EnvFile" }

  $cfgRaw = Get-Content $EnvFile -Raw
  $cfg = $cfgRaw | ConvertFrom-Json

  # APP_NAME
  $appName = "" + (Get-JsonPropValue $cfg "APP_NAME")
  $appName = $appName.Trim()
  if ([string]::IsNullOrWhiteSpace($appName)) { throw "APP_NAME missing in env json" }

  # API_BASE_URL
  $baseUrl = "" + (Get-JsonPropValue $cfg "API_BASE_URL")
  $baseUrl = $baseUrl.Trim()
  if ([string]::IsNullOrWhiteSpace($baseUrl)) { throw "API_BASE_URL missing in env json" }
  $baseUrl = $baseUrl.TrimEnd('/')

  # BRANDING block
  $branding = Get-JsonPropValue $cfg "BRANDING"
  if ($null -eq $branding) { throw "BRANDING block missing in env json" }

  # BRANDING.logoPath
  $logoPath = "" + (Get-JsonPropValue $branding "logoPath")
  $logoPath = $logoPath.Trim()
  if ([string]::IsNullOrWhiteSpace($logoPath)) { throw "BRANDING.logoPath missing in env json" }
  if (-not $logoPath.StartsWith("/")) { $logoPath = "/$logoPath" }

  # BRANDING.splashColor (optional)
  $splashColor = "" + (Get-JsonPropValue $branding "splashColor")
  $splashColor = $splashColor.Trim()
  if ([string]::IsNullOrWhiteSpace($splashColor)) { $splashColor = "#FFFFFF" }

  # Build logo URL
  $logoUrl = "$baseUrl$logoPath"
  Write-Host "Logo URL: $logoUrl"
  Write-Host "APP_NAME: $appName"
  Write-Host "Splash color: $splashColor"

  # ---------------- prepare assets ----------------
  Ensure-Dir "assets/branding"
  Ensure-Dir "tool"

  # Download logo (always overwrite)
  $logoOut = "assets/branding/logo.png"
  try {
    Invoke-WebRequest -Uri $logoUrl -OutFile $logoOut -UseBasicParsing
  } catch {
    throw "Failed to download logo from: $logoUrl`n$($_.Exception.Message)"
  }

  # Use same logo for launcher + splash
  Copy-Item $logoOut "assets/branding/launcher.png" -Force
  Copy-Item $logoOut "assets/branding/splash.png" -Force

  # ---------------- Android app name ----------------
  $stringsPath = "android/app/src/main/res/values/strings.xml"
  Ensure-Dir "android/app/src/main/res/values"

  if (!(Test-Path $stringsPath)) {
@"
<resources>
    <string name="app_name">$appName</string>
</resources>
"@ | Set-Content $stringsPath -Encoding UTF8
  } else {
    $strings = Get-Content $stringsPath -Raw
    if ($strings -match 'name="app_name"') {
      $strings = $strings -replace '(?s)(<string name="app_name">).*?(</string>)', "`$1$appName`$2"
    } else {
      $strings = $strings -replace '</resources>', "    <string name=`"app_name`">$appName</string>`n</resources>"
    }
    Set-Content $stringsPath $strings -Encoding UTF8
  }

  # Ensure AndroidManifest label uses @string/app_name
  $manifestPath = "android/app/src/main/AndroidManifest.xml"
  if (Test-Path $manifestPath) {
    $m = Get-Content $manifestPath -Raw
    $m = $m -replace 'android:label="[^"]*"', 'android:label="@string/app_name"'
    Set-Content $manifestPath $m -Encoding UTF8
  }

  # ---------------- iOS display name ----------------
  $plistPath = "ios/Runner/Info.plist"
  if (Test-Path $plistPath) {
    $plist = Get-Content $plistPath -Raw

    if ($plist -match '<key>CFBundleDisplayName</key>') {
      $plist = $plist -replace '(?s)(<key>CFBundleDisplayName</key>\s*<string>).*?(</string>)', "`$1$appName`$2"
    } else {
      # Inject before closing </dict>
      $inject = "  <key>CFBundleDisplayName</key>`n  <string>$appName</string>`n"
      $plist = $plist -replace '</dict>', "$inject</dict>"
    }

    Set-Content $plistPath $plist -Encoding UTF8
  }

  # ---------------- Generate icons + splash ----------------
  # Using cmd.exe /c ensures a clean exit code behavior for VSCode tasks
  Run-Ok "flutter pub get"
  Run-Ok "flutter pub run flutter_launcher_icons"
  Run-Ok "flutter pub run flutter_native_splash:create"

  Write-Host "✅ Branding applied from $EnvFile"

  # IMPORTANT: force success exit code for VSCode preLaunchTask
  exit 0
}
catch {
  Write-Host "❌ apply_env_branding failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
