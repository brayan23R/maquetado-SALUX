# Levanta TODO: panel admin (localhost:3000), emulador Pixel 8, app en el emulador y APK compartible.
# Uso (desde la raíz):  powershell -ExecutionPolicy Bypass -File scripts\levantar_todo.ps1 [-SinApk] [-SinAdmin]
param([switch]$SinApk, [switch]$SinAdmin, [string]$Avd = 'Pixel_8_API_37')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } elseif ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emulator = Join-Path $sdk 'emulator\emulator.exe'
$ndk = Join-Path $sdk 'ndk\28.2.13676358'

# 0. NDK completo (una descarga cortada deja la carpeta sin source.properties y rompe la compilación)
if ((Test-Path $ndk) -and -not (Test-Path (Join-Path $ndk 'source.properties'))) {
  Write-Host 'NDK incompleto: se borra para que se descargue de nuevo.' -ForegroundColor Yellow
  Remove-Item $ndk -Recurse -Force
}

# 1. Panel admin en otra ventana
if (-not $SinAdmin) {
  $admin = Join-Path $root 'apps\admin'
  if (-not (Test-Path (Join-Path $admin '.env.local'))) { Write-Host 'Falta apps\admin\.env.local (copia .env.example y complétalo).' -ForegroundColor Yellow }
  Start-Process powershell -ArgumentList '-NoExit', '-Command', "Set-Location '$admin'; if (-not (Test-Path node_modules)) { npm install }; npm run dev"
  Write-Host 'Panel admin: http://localhost:3000' -ForegroundColor Green
}

# 2. Emulador con aceleración de GPU/CPU del equipo
$running = & $adb devices | Select-String 'emulator-\d+\s+device'
if (-not $running) {
  Write-Host "Iniciando emulador $Avd..." -ForegroundColor Cyan
  Start-Process -FilePath $emulator -ArgumentList @('-avd', $Avd, '-gpu', 'host', '-accel', 'on', '-no-boot-anim', '-netdelay', 'none', '-netspeed', 'full', '-cores', '4', '-memory', '4096')
  & $adb wait-for-device
  do { Start-Sleep -Seconds 3; $boot = (& $adb shell getprop sys.boot_completed 2>$null) } while ("$boot".Trim() -ne '1')
}
$serial = ((& $adb devices | Select-String 'emulator-\d+\s+device') -split '\s+')[0]
Write-Host "Emulador listo: $serial" -ForegroundColor Green

# 3. APK compartible (se genera primero: es la compilación pesada y deja la caché lista)
flutter pub get
if (-not $SinApk) {
  flutter build apk --release --dart-define=APP_MODE=mock
  if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación del APK.' }
  New-Item -ItemType Directory -Force (Join-Path $root 'build') | Out-Null
  Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' (Join-Path $root 'build\SALUX.apk') -Force
  Write-Host "APK para compartir: $(Join-Path $root 'build\SALUX.apk')" -ForegroundColor Green
}

# 4. Instalar y abrir en el emulador (hot reload: r, salir: q)
flutter run -d $serial --dart-define=APP_MODE=mock
