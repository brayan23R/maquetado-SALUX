# Abre el emulador, compila e instala SALUX y la ejecuta. Uso: .\scripts\04_run_app.ps1 [-Mode mock|supabase] [-Avd SALUX_Pixel8]
param([ValidateSet('mock','supabase')][string]$Mode = 'mock', [string]$Avd = 'Pixel_8_API_37')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$app = $root  # La app Flutter vive en la raiz del proyecto
if (-not (Test-Path (Join-Path $app "pubspec.yaml"))) { throw "No se encontro pubspec.yaml en la raiz del proyecto." }
$sdk = $env:ANDROID_SDK_ROOT; if (-not $sdk) { $sdk = $env:ANDROID_HOME }; if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emulator = Join-Path $sdk 'emulator\emulator.exe'

$devices = & $adb devices | Select-String 'emulator-\d+\s+device'
if (-not $devices) {
  Write-Host "Iniciando emulador $Avd..."
  Start-Process -FilePath $emulator -ArgumentList @('-avd', $Avd, '-netdelay', 'none', '-netspeed', 'full') -WindowStyle Hidden
  & $adb wait-for-device
  do { Start-Sleep -Seconds 3; $boot = (& $adb shell getprop sys.boot_completed 2>$null).Trim() } while ($boot -ne '1')
  Write-Host 'Emulador listo.' -ForegroundColor Green
}

Set-Location $app
flutter pub get
if (Select-String -Path 'pubspec.yaml' -Pattern 'build_runner' -Quiet) { dart run build_runner build --delete-conflicting-outputs }

$defines = @("--dart-define=APP_MODE=$Mode")
if ($Mode -eq 'supabase' -and (Test-Path '.env.local')) {
  Get-Content '.env.local' | ForEach-Object { if ($_ -match '^(SUPABASE_URL|SUPABASE_ANON_KEY)=(.+)$') { $defines += "--dart-define=$($Matches[1])=$($Matches[2])" } }
}
Write-Host "Ejecutando SALUX en modo $Mode..." -ForegroundColor Cyan
flutter run -d emulator-5554 @defines
