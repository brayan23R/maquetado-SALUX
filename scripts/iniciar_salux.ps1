$ErrorActionPreference = "Stop"

$Project = "C:\ProyectosDev\SALUXPROTOTIPO"
$Admin = Join-Path $Project "apps\admin"
$Avd = "Pixel_8_API_37"
$Sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$Adb = Join-Path $Sdk "platform-tools\adb.exe"
$Emulator = Join-Path $Sdk "emulator\emulator.exe"

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "       INICIANDO SALUXPROTOTIPO" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# 1. Comprobar archivos esenciales
if (!(Test-Path "$Project\lib\main.dart")) {
    throw "No se encuentra lib\main.dart"
}
if (!(Test-Path "$Admin\node_modules\next\dist\bin\next")) {
    throw "No se encuentra Next.js en apps\admin"
}
if (!(Test-Path $Adb)) {
    throw "No se encuentra ADB en Android SDK"
}
if (!(Test-Path $Emulator)) {
    throw "No se encuentra el ejecutable del emulador"
}

# 2. Iniciar panel administrativo
Write-Host "`n[1/4] Iniciando panel administrativo..." -ForegroundColor Yellow

$adminCommand = "Set-Location '$Admin'; node .\node_modules\next\dist\bin\next dev -p 3000"

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-Command",
    $adminCommand
)

# 3. Comprobar o iniciar emulador
Write-Host "`n[2/4] Comprobando emulador Android..." -ForegroundColor Yellow

$devices = & $Adb devices

$emulatorOnline = $devices | Where-Object {
    $_ -match "^emulator-\d+\s+device$"
}

if (!$emulatorOnline) {
    Write-Host "Iniciando $Avd..."
    Start-Process -FilePath $Emulator -ArgumentList @("-avd", $Avd)
} else {
    Write-Host "Ya existe un emulador Android iniciado."
}

# 4. Esperar a que Android termine de arrancar
Write-Host "`n[3/4] Esperando el inicio completo de Android..." -ForegroundColor Yellow

$device = $null
$deadline = (Get-Date).AddMinutes(3)

do {
    Start-Sleep -Seconds 3

    $device = (& $Adb devices) | Where-Object {
        $_ -match "^(emulator-\d+)\s+device$"
    } | Select-Object -First 1

} while (!$device -and (Get-Date) -lt $deadline)

if (!$device) {
    throw "No se detectó un emulador Android disponible."
}

$deviceId = ($device -split "\s+")[0]

$booted = $false
$deadline = (Get-Date).AddMinutes(3)

do {
    $bootStatus = (& $Adb -s $deviceId shell getprop sys.boot_completed 2>$null |
        Out-String).Trim()

    if ($bootStatus -eq "1") {
        $booted = $true
        break
    }

    Start-Sleep -Seconds 3

} while ((Get-Date) -lt $deadline)

if (!$booted) {
    throw "Android no terminó de arrancar dentro del tiempo esperado."
}

Write-Host "Emulador listo: $deviceId" -ForegroundColor Green

# 5. Ejecutar Flutter en una consola independiente
Write-Host "`n[4/4] Iniciando aplicación Flutter..." -ForegroundColor Yellow

$flutterCommand = "Set-Location '$Project'; flutter run -d $deviceId"

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-Command",
    $flutterCommand
)

# 6. Abrir el panel en el navegador
Start-Sleep -Seconds 5
Start-Process "http://localhost:3000/login"

Write-Host "`n====================================" -ForegroundColor Green
Write-Host " SALUXPROTOTIPO: ARRANQUE SOLICITADO" -ForegroundColor Green
Write-Host " Panel: http://localhost:3000/login" -ForegroundColor Green
Write-Host " Emulador: $deviceId" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
