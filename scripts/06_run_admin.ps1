# Levanta el panel admin (Next.js) en http://localhost:3000. Uso: .\scripts\06_run_admin.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$admin = Join-Path $root 'apps\admin'
if (-not (Test-Path $admin)) { throw 'No existe apps\admin. Pídele a Codex que ejecute la Fase 5.' }
Set-Location $admin
if (-not (Test-Path 'node_modules')) { npm install }
npm run dev
