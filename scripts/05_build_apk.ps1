# Genera el APK. Uso: .\scripts\05_build_apk.ps1 [-Release] [-Mode mock|supabase]
param([switch]$Release, [ValidateSet('mock','supabase')][string]$Mode = 'mock')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$app = $root  # La app Flutter vive en la raiz del proyecto
Set-Location $app
flutter pub get
if (Select-String -Path 'pubspec.yaml' -Pattern 'build_runner' -Quiet) { dart run build_runner build --delete-conflicting-outputs }
$defines = @("--dart-define=APP_MODE=$Mode")
if ($Mode -eq 'supabase' -and (Test-Path '.env.local')) {
  Get-Content '.env.local' | ForEach-Object { if ($_ -match '^(SUPABASE_URL|SUPABASE_ANON_KEY)=(.+)$') { $defines += "--dart-define=$($Matches[1])=$($Matches[2])" } }
}
New-Item -ItemType Directory -Force -Path (Join-Path $root 'build') | Out-Null
if ($Release) {
  if (-not (Test-Path 'android\key.properties')) { Write-Host 'Aviso: no hay android\key.properties; se firmará con la llave de depuración (solo para pruebas).' -ForegroundColor Yellow }
  flutter build apk --release --obfuscate --split-debug-info=build\symbols @defines
  Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' (Join-Path $root 'build\SALUX-release.apk') -Force
  Write-Host "APK: $(Join-Path $root 'build\SALUX-release.apk')" -ForegroundColor Green
} else {
  flutter build apk --debug @defines
  Copy-Item 'build\app\outputs\flutter-apk\app-debug.apk' (Join-Path $root 'build\SALUX-debug.apk') -Force
  Write-Host "APK: $(Join-Path $root 'build\SALUX-debug.apk')" -ForegroundColor Green
}
