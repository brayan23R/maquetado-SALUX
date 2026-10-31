# Crea el emulador Android "SALUX_Pixel8" (Pixel 8, imagen x86_64 con Google Play). Uso: .\scripts\02_create_emulator.ps1
param([string]$AvdName = 'SALUX_Pixel8')
$ErrorActionPreference = 'Stop'
$sdk = $env:ANDROID_SDK_ROOT; if (-not $sdk) { $sdk = $env:ANDROID_HOME }; if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$sdkmanager = Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
$avdmanager = Join-Path $sdk 'cmdline-tools\latest\bin\avdmanager.bat'
$emulator   = Join-Path $sdk 'emulator\emulator.exe'
if (-not (Test-Path $sdkmanager)) { throw "Falta Android SDK Command-line Tools (latest). Instálalos desde Android Studio > SDK Manager > SDK Tools." }

$existing = & $emulator -list-avds 2>$null
if ($existing -contains $AvdName) { Write-Host "El emulador $AvdName ya existe." -ForegroundColor Green; exit 0 }

Write-Host 'Aceptando licencias del SDK...'
('y' * 30 -split '') | & $sdkmanager --licenses *> $null

Write-Host 'Buscando la imagen de sistema más reciente (Google Play, x86_64)...'
$list = & $sdkmanager --list 2>$null | Out-String
$found = [regex]::Matches($list, 'system-images;android-(\d+);google_apis_playstore;x86_64')
if ($found.Count -eq 0) { throw 'No se encontró ninguna imagen google_apis_playstore x86_64. Revisa tu conexión o instala una desde Android Studio.' }
$api = ($found | ForEach-Object { [int]$_.Groups[1].Value } | Sort-Object -Unique | Select-Object -Last 1)
$image = "system-images;android-$api;google_apis_playstore;x86_64"
Write-Host "Instalando $image (puede tardar varios minutos)..."
& $sdkmanager $image 'emulator' 'platform-tools'
if ($LASTEXITCODE -ne 0) { throw 'Falló la instalación de la imagen.' }

Write-Host "Creando $AvdName..."
'no' | & $avdmanager create avd -n $AvdName -k $image -d pixel_8 --force
if ($LASTEXITCODE -ne 0) { throw 'Falló la creación del emulador.' }

# Ajustes de rendimiento
$cfg = Join-Path $env:USERPROFILE ".android\avd\$AvdName.avd\config.ini"
if (Test-Path $cfg) {
  Add-Content $cfg "`nhw.ramSize=4096`nvm.heapSize=512`nhw.gpu.enabled=yes`nhw.gpu.mode=auto`nhw.keyboard=yes"
}
Write-Host "Emulador $AvdName listo." -ForegroundColor Green
