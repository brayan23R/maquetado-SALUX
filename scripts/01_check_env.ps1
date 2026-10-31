# Diagnóstico del entorno. Uso: .\scripts\01_check_env.ps1
$ErrorActionPreference = 'Continue'
function Test-Tool($name, $cmd, $required = $true, $hint = '') {
  $found = Get-Command $cmd -ErrorAction SilentlyContinue
  if ($found) { Write-Host ("[OK]   {0,-14} {1}" -f $name, $found.Source) -ForegroundColor Green; return $true }
  $level = if ($required) { 'FALTA' } else { 'opcional' }
  Write-Host ("[{0}] {1,-14} {2}" -f $level, $name, $hint) -ForegroundColor Yellow
  return (-not $required)
}
$ok = $true
$ok = (Test-Tool 'Flutter'  'flutter'  $true 'Instala Flutter y agrégalo al PATH') -and $ok
$ok = (Test-Tool 'Dart'     'dart'     $true 'Viene con Flutter') -and $ok
$ok = (Test-Tool 'Git'      'git'      $true 'https://git-scm.com') -and $ok
$ok = (Test-Tool 'Node'     'node'     $true 'https://nodejs.org (LTS)') -and $ok
$ok = (Test-Tool 'npm'      'npm'      $true 'Viene con Node') -and $ok
$ok = (Test-Tool 'Docker'   'docker'   $true 'Instala Docker Desktop y ábrelo') -and $ok
$null = Test-Tool 'Supabase CLI' 'supabase' $false 'Se usará "npx supabase" si no está instalado'
$null = Test-Tool 'Java'    'java'     $false 'Android Studio incluye un JDK'

$sdk = $env:ANDROID_SDK_ROOT
if (-not $sdk) { $sdk = $env:ANDROID_HOME }
if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
if (Test-Path $sdk) { Write-Host "[OK]   Android SDK    $sdk" -ForegroundColor Green } else { Write-Host "[FALTA] Android SDK   Instala Android Studio y el SDK" -ForegroundColor Red; $ok = $false }
$adb = Join-Path $sdk 'platform-tools\adb.exe'
if (Test-Path $adb) { Write-Host "[OK]   adb            $adb" -ForegroundColor Green } else { Write-Host "[FALTA] adb           Android Studio > SDK Manager > Platform-Tools" -ForegroundColor Red; $ok = $false }
$sdkm = Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
if (Test-Path $sdkm) { Write-Host "[OK]   cmdline-tools  $sdkm" -ForegroundColor Green } else { Write-Host "[FALTA] cmdline-tools Android Studio > SDK Manager > SDK Tools > Android SDK Command-line Tools (latest)" -ForegroundColor Red; $ok = $false }

if (Get-Command docker -ErrorAction SilentlyContinue) {
  docker info *> $null
  if ($LASTEXITCODE -eq 0) { Write-Host '[OK]   Docker está corriendo' -ForegroundColor Green } else { Write-Host '[FALTA] Docker Desktop no está abierto. Ábrelo y espera a que diga "Running".' -ForegroundColor Yellow; $ok = $false }
}
Write-Host ''
if (Get-Command flutter -ErrorAction SilentlyContinue) { flutter doctor -v }
if ($ok) { Write-Host "`nEntorno listo." -ForegroundColor Green; exit 0 } else { Write-Host "`nHay elementos por corregir (ver arriba)." -ForegroundColor Yellow; exit 1 }
