# Todo en uno: verifica entorno, crea emulador, levanta backend, instala la app y la abre. Uso: .\scripts\00_bootstrap.ps1 [-Mode mock|supabase] [-WithAdmin]
param([ValidateSet('mock','supabase')][string]$Mode = 'mock', [switch]$WithAdmin)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
Write-Host '== 1/4 Verificando entorno ==' -ForegroundColor Cyan
& "$here\01_check_env.ps1"
if ($LASTEXITCODE -ne 0) { throw 'Corrige lo indicado y vuelve a ejecutar.' }
Write-Host '== 2/4 Emulador Android ==' -ForegroundColor Cyan
& "$here\02_create_emulator.ps1"
if ($Mode -eq 'supabase' -or $WithAdmin) {
  Write-Host '== 3/4 Backend local ==' -ForegroundColor Cyan
  & "$here\03_start_backend.ps1"
} else { Write-Host '== 3/4 Backend omitido (modo mock) ==' -ForegroundColor DarkGray }
if ($WithAdmin) { Start-Process powershell -ArgumentList '-NoExit', '-File', "$here\06_run_admin.ps1" }
Write-Host '== 4/4 Instalando y abriendo SALUX ==' -ForegroundColor Cyan
& "$here\04_run_app.ps1" -Mode $Mode
